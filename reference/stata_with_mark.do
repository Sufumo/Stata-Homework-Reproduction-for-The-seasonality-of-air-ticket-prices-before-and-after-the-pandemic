/*-------------------------------------------------
研究标题：航空票价季节性分析
数据来源：巴西航空经济中心 avdatabr_cp_cae 数据集
数据链接：https://doi.org/10.7910/DVN/CRYXUZ
研究目的：分析巴西国内航线票价的季节性模式及疫情前后变化
-------------------------------------------------*/

* 代码要求：需要Stata 14或更高版本

*----------------------------
* 第一部分：Stata环境设置
*----------------------------

/* 以下用户编写的Stata模块对本代码的执行是必需的 */

* 安装fsum模块：用于快速描述性统计
ssc install fsum

* 安装ftools模块：提供高效的函数工具
capture ado uninstall ftools // 如果之前安装过，先卸载
net install ftools, from("https://raw.githubusercontent.com/sergiocorreia/ftools/master/src/")

* 安装reghdfe模块：支持高维固定效应回归
capture ado uninstall reghdfe // 如果之前安装过，先卸载
net install reghdfe, from("https://raw.githubusercontent.com/sergiocorreia/reghdfe/master/src/")

* 安装estout模块：用于回归结果输出和表格制作
ssc install estout, replace
help esttab // 查看esttab帮助文档

* 安装coefplot模块：用于系数图绘制
ssc install coefplot, replace
help coefplot // 查看coefplot帮助文档


*----------------------------
* 第二部分：数据导入
*----------------------------

* 从哈佛Dataverse导入航空票价数据集
import delimited ///
https://dataverse.harvard.edu/api/access/datafile/avdatabr_cp_cae/8171526, ///
case(preserve) clear
* case(preserve) 保留变量名原始大小写
* clear 清除内存中现有数据


*----------------------------
* 第三部分：样本筛选
*----------------------------

* 保留2013年及以后的数据
keep if Year>=2013 

* 生成平均飞机规模变量：可用座位数/出发班次
gen mean_aircsize = nr_available_seats/nr_departures

* 查看平均飞机规模的描述性统计
summ mean_aircsize

* 删除平均飞机规模小于50的观测值（排除小型航线）
drop if mean_aircsize<50

* 删除非常不平衡的面板数据（少于5年数据）
* 按城市对分组，生成每个城市对的观测数量
bysort CityPair: gen nr_panels = [_N]

* 查看面板观测数量的分布
summ nr_panels

* 删除观测数量少于60的城市对
drop if nr_panels<60


* 显示最终样本的面板结构信息
* 城市对数量
tab CityPair
di "城市对数量 = " `r(r)'

* 时间期数（月份）
tab YearMonth
di "时间期数 = " `r(r)'

* 年份数量
tab Year
di "年份数量 = " `r(r)'


*----------------
* 第四部分：面板数据声明
*----------------

* 生成城市对编码变量
egen k = group(CityPair)

* 生成时间期编码变量
egen t = group(YearMonth)

* 声明面板数据格式：k为个体维度，t为时间维度
tsset k t


*----------------
* 第五部分：变量处理与生成
*----------------

* 从原始数据集中提取需要的变量
keep k t price km_great_circle_distance jetfuel_price_org ///
	 nr_revenue_pax market_concentration_hhi pc_load_factor ///
	 YearMonth Year Month CityPair

* 描述性统计：排除时间标识变量
fsum, not(YearMonth k t) format(%10.2f)

* 生成模型所需的转换变量
* 被解释变量：机票价格的对数
gen AirFare = ln(price)

* 核心解释变量：距离的对数
gen Distance = ln(km_great_circle_distance)

* 核心解释变量：燃油价格的对数
gen FuelPrice = ln(jetfuel_price_org)

* 核心解释变量：乘客密度的对数
gen PaxDens = ln(nr_revenue_pax)

* 核心解释变量：市场集中度的对数（乘以10000避免取对数问题）
gen MktConc = ln(market_concentration_hhi*10000)

* 核心解释变量：载客率的对数
gen LoadFactor = ln(pc_load_factor)

* 疫情虚拟变量：2020年2月-2022年4月期间为1，其余为0
gen Pandemic = (YearMonth>=202002 & YearMonth<=202204)

* 时间趋势变量：将时间标准化到0-2.18范围
gen Trend = t/60

* 转换后变量的描述性统计
fsum AirFare Distance FuelPrice PaxDens MktConc ///
	 LoadFactor Pandemic Trend

*----------------
* 第六部分：季节性变量生成
*----------------

* 冬季假期虚拟变量：7月为1（巴西学校冬季假期）
gen WintBreak = (Month==7)

* 夏季搜索期虚拟变量：8-11月为1（夏季高峰前的搜索预订期）
gen SummBrSearch = (Month==8 | Month==9 | Month==10 | Month==11)

* 夏季高峰虚拟变量：12月-次年2月为1（巴西夏季旅游高峰）
* 基准组：3月
gen SummBreak = (Month==12 | Month==1 | Month==2) // base case = 3

* 淡季虚拟变量：4-6月为1（旅游淡季）
gen LowSeason = (Month==4 | Month==5 | Month==6)


*-------------------------
* 实验一：基础季节性控制
*-------------------------

* 无季节性控制的固定效应回归
reghdfe AirFare FuelPrice PaxDens MktConc LoadFactor ///
	Pandemic Trend ///
	, absorb(CityPair)
* absorb(CityPair)：控制城市对固定效应

* 存储回归结果
est store WithoutSeas

* 包含季节性控制的固定效应回归
reghdfe AirFare FuelPrice PaxDens MktConc LoadFactor ///
	Pandemic Trend ///
	WintBreak SummBrSearch SummBreak LowSeason ///
	, absorb(CityPair)

* 存储回归结果
est store WithSeas

* 显示结果对比表格
esttab 	WithoutSeas WithSeas ///
		, nocons nose not nogaps noobs ///
		b(%9.4f) varwidth(14) brackets ///
		aic(%9.0fc) bic(%9.0fc) ar2 scalar(N) sfmt(%9.0fc) ///
		addnote("Notes: Fixed Effect estimation")
* nocons: 不显示常数项
* nose: 不显示标准误
* not: 不显示t统计量
* nogaps: 无间隔
* noobs: 不显示观测值数量
* b(%9.4f): 系数格式
* brackets: 标准误放在括号中


*-------------------------
* 实验二：精细化季节性分析
*-------------------------

* 生成更细粒度的月度虚拟变量
* 夏季前4个月：8月
gen SummBreak_bef4 = (Month==8)
* 夏季前3个月：9月
gen SummBreak_bef3 = (Month==9)
* 夏季前2个月：10月
gen SummBreak_bef2 = (Month==10)
* 夏季前1个月：11月
gen SummBreak_bef1 = (Month==11)
* 夏季开始月：12月
gen SummBreak_aft0 = (Month==12)
* 夏季后1个月：1月
gen SummBreak_aft1 = (Month==1)
* 夏季后2个月：2月
gen SummBreak_aft2 = (Month==2)
* 淡季第1个月：4月（基准组为3月）
gen LowSeason_aft1 = (Month==4) // base case p0
* 淡季第2个月：5月
gen LowSeason_aft2 = (Month==5)
* 淡季第3个月：6月
gen LowSeason_aft3 = (Month==6)

* 包含精细化季节性的固定效应回归
* 使用通配符 * 包含所有相关变量
reghdfe AirFare FuelPrice PaxDens MktConc LoadFactor ///
	Pandemic Trend ///
	WintBreak SummBreak_* LowSeason_* ///
	, absorb(CityPair)

* 存储回归结果
est store GranularSeas

* 显示精细化季节性回归结果
esttab 	GranularSeas ///
		, nocons nose not nogaps noobs ///
		b(%9.4f) varwidth(14) brackets ///
		aic(%9.0fc) bic(%9.0fc) ar2 scalar(N) sfmt(%9.0fc) ///
		addnote("Notes: Fixed Effect estimation")

* 绘制季节性系数图
coefplot GranularSeas ///
		, keep(WintBreak SummBreak_* SummBreak_* LowSeason_*) ///
		xline(0, lcolor(green) lpattern(dash)) scheme(s2color) ///
		level(95) recast(connected) lpattern(longdash) lwidth(0.1)
* keep(): 指定要绘制的变量
* xline(0): 在x=0处添加参考线
* scheme(s2color): 使用s2color配色方案
* level(95): 95%置信区间
* recast(connected): 连线图形式


*-------------------------
* 实验三：疫情前后事件研究
*-------------------------

* 疫情前样本回归（2013年1月-2020年1月）
reghdfe AirFare FuelPrice PaxDens MktConc LoadFactor ///
	Trend WintBreak SummBreak_* LowSeason_* ///
	if YearMonth<=202001, absorb(CityPair)

* 存储疫情前回归结果
est store PrePandemic

* 疫情后样本回归（2022年5月-2023年11月）
reghdfe AirFare FuelPrice PaxDens MktConc LoadFactor ///
	Trend WintBreak SummBreak_* LowSeason_* ///
	if YearMonth>202204, absorb(CityPair)

* 存储疫情后回归结果
est store PostPandemic

* 显示疫情前后对比结果表格
esttab 	PrePandemic PostPandemic ///
		, nocons nose not nogaps noobs mtitles ///
		b(%9.4f) varwidth(14) brackets ///
		aic(%9.0fc) bic(%9.0fc) ar2 scalar(N) sfmt(%9.0fc) ///
		addnote("Notes: Dependent variable - AirFare" ///
		"Fixed Effect estimation")
* mtitles: 显示模型标题

* 绘制疫情前后季节性系数对比图
coefplot PrePandemic PostPandemic ///
		, keep(WintBreak SummBreak_* SummBreak_* LowSeason_*) ///
		xline(0, lcolor(green) lpattern(dash)) scheme(s2color) ///
		level(95) recast(connected) lpattern(longdash) lwidth(0.1)
* 同时显示疫情前和疫情后的系数，便于对比结构性变化