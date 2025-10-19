# Table 1 – Descriptive statistics of the variables

| Variable   | N     | Mean | SD   | Min  | Max  |
|-------------|-------|------|------|------|------|
| AirFare     | 55950 | 6.25 | 0.40 | 4.11 | 8.29 |
| Distance    | 55950 | 6.65 | 0.68 | 4.68 | 7.95 |
| FuelPrice   | 55950 | 1.10 | 0.28 | 0.43 | 1.82 |
| PaxDens     | 55950 | 8.63 | 1.47 | 2.20 | 12.98 |
| MktConc     | 55950 | 8.61 | 0.39 | 7.80 | 9.21 |
| LoadFactor  | 55950 | 4.33 | 0.15 | 2.57 | 4.61 |
| Pandemic    | 55950 | 0.18 | 0.39 | 0.00 | 1.00 |
| Trend       | 55950 | 1.10 | 0.62 | 0.02 | 2.18 |

---

# Table 2 – Models Without and With Seasonality Controls

| Variables   | (1) AirFare | (2) AirFare |
|--------------|-------------|-------------|
| FuelPrice    | 0.2931***   | 0.2897***   |
| PaxDens      | -0.0888***  | -0.0937***  |
| MktConc      | 0.0854***   | 0.0859***   |
| LoadFactor   | 0.3121***   | 0.2935***   |
| Pandemic     | -0.1674***  | -0.1690***  |
| Trend        | 0.0215***   | 0.0180***   |
| WintBreak    |             | -0.0009     |
| SummBrSearch |             | 0.0593***   |
| SummBreak    |             | 0.0145***   |
| LowSeason    |             | -0.0452***  |
| adj. R-sq    | 0.579       | 0.588       |
| AIC          | 8,539       | 7,265       |
| BIC          | 8,601       | 7,363       |
| N            | 55,950      | 55,950      |

Notes: Fixed Effect estimation  
* p<0.05, ** p<0.01, *** p<0.001

---

# Table 3 – Model with Granular Seasonality

| Variables        | (1) AirFare |
|-------------------|-------------|
| FuelPrice         | 0.2910***   |
| PaxDens           | -0.0941***  |
| MktConc           | 0.0865***   |
| LoadFactor        | 0.2950***   |
| Pandemic          | -0.1677***  |
| Trend             | 0.0167***   |
| WintBreak         | -0.0008     |
| SummBreak_bef4    | 0.0563***   |
| SummBreak_bef3    | 0.0688***   |
| SummBreak_bef2    | 0.0812***   |
| SummBreak_bef1    | 0.0315***   |
| SummBreak_aft0    | 0.0609***   |
| SummBreak_aft1    | -0.0156**   |
| SummBreak_aft2    | 0.0020      |
| LowSeason_aft1    | -0.0492***  |
| LowSeason_aft2    | -0.0380***  |
| LowSeason_aft3    | -0.0482***  |
| adj. R-sq         | 0.591       |
| AIC               | 6,957       |
| BIC               | 7,117       |
| N                 | 55,950      |

Notes: Fixed Effect estimation  
* p<0.05, ** p<0.01, *** p<0.001

---

# Table 4 – Event study: before and after the Pandemic

| Variables        | (1) PrePandemic | (2) PostPandemic |
|-------------------|------------------|-------------------|
| FuelPrice         | 0.1677***        | 0.0681*           |
| PaxDens           | -0.1608***       | -0.1466***        |
| MktConc           | 0.0889***        | -0.0582***        |
| LoadFactor        | 0.3020***        | 0.1889***         |
| Trend             | -0.0244***       | 0.2301***         |
| WintBreak         | 0.0668***        | -0.0293*          |
| SummBreak_bef4    | 0.0822***        | 0.0688***         |
| SummBreak_bef3    | 0.0878***        | 0.0876***         |
| SummBreak_bef2    | 0.1178***        | 0.0559***         |
| SummBreak_bef1    | 0.0686***        | 0.0313*           |
| SummBreak_aft0    | 0.1107***        | 0.0546***         |
| SummBreak_aft1    | 0.0263***        | -0.0176           |
| SummBreak_aft2    | 0.0181**         | -0.0486**         |
| LowSeason_aft1    | -0.0265***       | -0.1048***        |
| LowSeason_aft2    | -0.0125*         | -0.0269*          |
| LowSeason_aft3    | -0.0138*         | -0.0444**         |
| adj. R-sq         | 0.647            | 0.722             |
| AIC               | -3,381           | -2,558            |
| BIC               | -3,236           | -2,439            |
| N                 | 37,441           | 8,373             |

Notes: Dependent variable - AirFare  
Fixed Effect estimation  
* p<0.05, ** p<0.01, *** p<0.001
