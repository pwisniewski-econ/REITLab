INTEREST_RATES <- arrow::read_feather("data/imported/interest_rates.feather")

ls_tickers <- c(
  "MPW",    # 1. Medical Properties Trust
  "BRT",    # 2. BRT APARTMENTS CORP
  "CPT",    # 3. Camden Property Trust
  "SUI",    # 4. Sun Communities Inc
  "DRE",    # 5. Duke Realty Corporation
  "PLD",    # 6. Prologis Inc
  "AHT",    # 7. Ashford Hospitality Trust, Inc.
  "AIV",    # 8. Apartment Investment & Management Co.
  "CMCT",   # 9. CIM COMMERCIAL TRUST CORPORATION
  "EQIX",   # 10. EQUINIX INC
  "SBAC",   # 11. SBA COMMUNICATIONS CORPORATION
  "LTC",    # 12. LTC PROPERTIES INC
  "SVC",    # 13. SERVICE PROPERTIES TRUST
  "REG",    # 14. REGENCY CENTERS CORPORATION
  "LAMR",   # 15. LAMAR ADVERTISING COMPANY
  "GOOD",   # 16. Gladstone Commercial Corporation
  "BDN",    # 17. Brandywine Realty Trust
  "CCI",    # 18. Crown Castle Inc
  "CUBE",   # 19. CubeSmart
  "OLP",    # 20. One Liberty Properties Inc
  "CSR",    # 21. Centerspace
  "COV.PA", # 22. COVIVIO SA
  "GFC.PA", # 23. GECINA REIT SA
  "ICAD.PA", # 24. ICADE REIT SA
  "LI.PA",  # 25. KLEPIERRE REIT SA
  "MERY.PA", # 26. MERCIALYS REIT SA
  "PHP.L",  # 27. PRIMARY HEALTH PROPERTIES REIT PLC
  "DLN.L",  # 28. DERWENT LONDON REIT PLC
  "RDI",    # 29. RDI REIT PLC
  "HAB.DE", # 30. HAMBORNER REIT
  "WDP.BR", # 31. WAREHOUSES DE PAUW REIT
  "AED.BR", # 32. AEDIFICA REIT SA
  "COFB.BR",   # 33. COFINIMMO REIT SA
  "ASCE.BR",   # 34. ASCENCIO SCA REIT
  "RET.BR", # 35. RETAIL ESTATES NV
  "WEHB.BR",# 36. WERELDHAVE BELGIUM CVA REIT
  "AOX.DE", # 37. ALSTRIA OFFICE REIT
  "IIA.VI", # 38. IMMOFINANZ AG
  "GPE.L",  # 39. GREAT PORTLAND ESTATES REIT PLC
  "WKP.L",  # 40. WORKSPACE GROUP REIT PLC
  "SGRO.L", # 41. SEGRO Plc
  "MONT.BR", # 42. MONTEA COMM. VA
  "SURVF",  # 43. Suntec Real Estate Investment Trust
  "KREVF",  # 44. Keppel REIT
  "SGLMF",  # 45. Starhill Global Real Estate Investment Trust
  "CDHSF",  # 46. CDL Hospitality Trusts
  "PRKWF",  # 47. Parkway Life REIT
  "MAPGF",  # 48. Mapletree Logistics Trust
  "ATTRF",  # 49. CapitaLand Ascott Trust
  "CPAMF",  # 50. CapitaLand Integrated Commercial Trust
  "JREIF",  # 51. Japan Real Estate Investment Corp
  "ORXJF",  # 52. Orix JREIT Inc
  "JPRRF",  # 53. Japan Prime Realty Investment Corp.
  "TKURF",  # 54. Tokyu Reit Inc
  "8958.T",  # 55. Global One Real Estate Investment Corp
  "8966.T",  # 56. Heiwa Real Estate Reit Inc
  "8967.T",  # 57. Japan Logistics Fund Inc.
  "8968.T",  # 58. Fukuoka REIT Corp
  "8977.T",  # 59. Hankyu Hanshin REIT Inc
  "NIPPF",  # 60. Nippon Accommodations Fund Inc.
  "NBFJF",  # 61. Nippon Building Fund
  "A17U.SI",  # 62. CapitaLand Ascendas REIT
  "8961.T"   # 63. MORI TRUST REIT INC
)

ls_countries <- c(
  "US", # MPW, BRT, CPT, SUI, DRE, PLD, AHT, AIV, CMCT, EQIX, SBAC, LTC, SVC, REG, LAMR, GOOD, BDN, CCI, CUBE, OLP, CSR
  "FR", # COV.PA, GFC.PA, ICAD.PA, LI.PA, MERY.PA
  "GB", # PHP.L, DLN.L, GPE.L, WKP.L, SGRO.L
  "DE", # HAB.DE, AOX.DE
  "BE", # WDP.BR, AED.BR, COFB.BR, ASCE.BR, RET.BR, WEHB.BR, MONT.BR
  "AT", # IIA.VI
  "SG", # SURVF, KREVF, SGLMF, CDHSF, PRKWF, MAPGF, ATTRF, CPAMF, A17U.SI
  "JP"  # JREIF, ORXJF, JPRRF, TKURF, 8958.T, 8966.T, 8967.T, 8968.T, 8977.T, NIPPF, NBFJF, 8961.T
)

COUNTRIES_AREA <- data.frame(
  country = c("United States", "France", "United Kingdom", "Germany", "Belgium", "Austria", "Singapore", "Japan"),
  area_km2 = c(
    9833520,  # United States
    551695,   # France (metropolitan)
    243610,   # United Kingdom
    357022,   # Germany
    30689 ,   # Belgium
    83879,    # Austria
    728.6,    # Singapore
    377975    # Japan
  )
)