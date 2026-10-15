.pragma library

var CURATED_CITIES = [
  { label: "NYC", city: "New York", country: "US", countryName: "United States", tz: "America/New_York" },
  { label: "WAS", city: "Washington DC", country: "US", countryName: "United States", tz: "America/New_York" },
  { label: "BOS", city: "Boston", country: "US", countryName: "United States", tz: "America/New_York" },
  { label: "MIA", city: "Miami", country: "US", countryName: "United States", tz: "America/New_York" },
  { label: "ATL", city: "Atlanta", country: "US", countryName: "United States", tz: "America/New_York" },
  { label: "CHI", city: "Chicago", country: "US", countryName: "United States", tz: "America/Chicago" },
  { label: "DAL", city: "Dallas", country: "US", countryName: "United States", tz: "America/Chicago" },
  { label: "HOU", city: "Houston", country: "US", countryName: "United States", tz: "America/Chicago" },
  { label: "AUS", city: "Austin", country: "US", countryName: "United States", tz: "America/Chicago" },
  { label: "DEN", city: "Denver", country: "US", countryName: "United States", tz: "America/Denver" },
  { label: "PHX", city: "Phoenix", country: "US", countryName: "United States", tz: "America/Phoenix" },
  { label: "SFO", city: "San Francisco", country: "US", countryName: "United States", tz: "America/Los_Angeles" },
  { label: "LAX", city: "Los Angeles", country: "US", countryName: "United States", tz: "America/Los_Angeles" },
  { label: "SEA", city: "Seattle", country: "US", countryName: "United States", tz: "America/Los_Angeles" },
  { label: "HAW", city: "Hawaii", country: "US", countryName: "United States", tz: "Pacific/Honolulu" },
  { label: "HNL", city: "Honolulu", country: "US", countryName: "United States", tz: "Pacific/Honolulu" },
  { label: "YYZ", city: "Toronto", country: "CA", countryName: "Canada", tz: "America/Toronto" },
  { label: "YVR", city: "Vancouver", country: "CA", countryName: "Canada", tz: "America/Vancouver" },
  { label: "YUL", city: "Montreal", country: "CA", countryName: "Canada", tz: "America/Toronto" },
  { label: "MEX", city: "Mexico City", country: "MX", countryName: "Mexico", tz: "America/Mexico_City" },
  { label: "GRU", city: "Sao Paulo", country: "BR", countryName: "Brazil", tz: "America/Sao_Paulo" },
  { label: "EZE", city: "Buenos Aires", country: "AR", countryName: "Argentina", tz: "America/Argentina/Buenos_Aires" },
  { label: "LDN", city: "London", country: "UK", countryName: "United Kingdom", tz: "Europe/London" },
  { label: "DUB", city: "Dublin", country: "IE", countryName: "Ireland", tz: "Europe/Dublin" },
  { label: "LIS", city: "Lisbon", country: "PT", countryName: "Portugal", tz: "Europe/Lisbon" },
  { label: "PAR", city: "Paris", country: "FR", countryName: "France", tz: "Europe/Paris" },
  { label: "BER", city: "Berlin", country: "DE", countryName: "Germany", tz: "Europe/Berlin" },
  { label: "FRA", city: "Frankfurt", country: "DE", countryName: "Germany", tz: "Europe/Berlin" },
  { label: "MUC", city: "Munich", country: "DE", countryName: "Germany", tz: "Europe/Berlin" },
  { label: "AMS", city: "Amsterdam", country: "NL", countryName: "Netherlands", tz: "Europe/Amsterdam" },
  { label: "BRU", city: "Brussels", country: "BE", countryName: "Belgium", tz: "Europe/Brussels" },
  { label: "ZRH", city: "Zurich", country: "CH", countryName: "Switzerland", tz: "Europe/Zurich" },
  { label: "GVA", city: "Geneva", country: "CH", countryName: "Switzerland", tz: "Europe/Zurich" },
  { label: "MAD", city: "Madrid", country: "ES", countryName: "Spain", tz: "Europe/Madrid" },
  { label: "BCN", city: "Barcelona", country: "ES", countryName: "Spain", tz: "Europe/Madrid" },
  { label: "ROM", city: "Rome", country: "IT", countryName: "Italy", tz: "Europe/Rome" },
  { label: "MIL", city: "Milan", country: "IT", countryName: "Italy", tz: "Europe/Rome" },
  { label: "VIE", city: "Vienna", country: "AT", countryName: "Austria", tz: "Europe/Vienna" },
  { label: "STO", city: "Stockholm", country: "SE", countryName: "Sweden", tz: "Europe/Stockholm" },
  { label: "OSL", city: "Oslo", country: "NO", countryName: "Norway", tz: "Europe/Oslo" },
  { label: "CPH", city: "Copenhagen", country: "DK", countryName: "Denmark", tz: "Europe/Copenhagen" },
  { label: "WAW", city: "Warsaw", country: "PL", countryName: "Poland", tz: "Europe/Warsaw" },
  { label: "PRG", city: "Prague", country: "CZ", countryName: "Czechia", tz: "Europe/Prague" },
  { label: "ATH", city: "Athens", country: "GR", countryName: "Greece", tz: "Europe/Athens" },
  { label: "IST", city: "Istanbul", country: "TR", countryName: "Turkey", tz: "Europe/Istanbul" },
  { label: "CAI", city: "Cairo", country: "EG", countryName: "Egypt", tz: "Africa/Cairo" },
  { label: "CMN", city: "Casablanca", country: "MA", countryName: "Morocco", tz: "Africa/Casablanca" },
  { label: "LOS", city: "Lagos", country: "NG", countryName: "Nigeria", tz: "Africa/Lagos" },
  { label: "NBO", city: "Nairobi", country: "KE", countryName: "Kenya", tz: "Africa/Nairobi" },
  { label: "JNB", city: "Johannesburg", country: "ZA", countryName: "South Africa", tz: "Africa/Johannesburg" },
  { label: "DXB", city: "Dubai", country: "AE", countryName: "United Arab Emirates UAE", tz: "Asia/Dubai" },
  { label: "AUH", city: "Abu Dhabi", country: "AE", countryName: "United Arab Emirates UAE", tz: "Asia/Dubai" },
  { label: "RUH", city: "Riyadh", country: "SA", countryName: "Saudi Arabia KSA", tz: "Asia/Riyadh" },
  { label: "JED", city: "Jeddah", country: "SA", countryName: "Saudi Arabia KSA", tz: "Asia/Riyadh" },
  { label: "MKK", city: "Makkah", country: "SA", countryName: "Saudi Arabia KSA", tz: "Asia/Riyadh" },
  { label: "MED", city: "Madinah", country: "SA", countryName: "Saudi Arabia KSA", tz: "Asia/Riyadh" },
  { label: "BAG", city: "Baghdad", country: "IQ", countryName: "Iraq", tz: "Asia/Baghdad" },
  { label: "DOH", city: "Doha", country: "QA", countryName: "Qatar", tz: "Asia/Qatar" },
  { label: "KWI", city: "Kuwait City", country: "KW", countryName: "Kuwait", tz: "Asia/Kuwait" },
  { label: "BAH", city: "Manama", country: "BH", countryName: "Bahrain", tz: "Asia/Bahrain" },
  { label: "MCT", city: "Muscat", country: "OM", countryName: "Oman", tz: "Asia/Muscat" },
  { label: "AMM", city: "Amman", country: "JO", countryName: "Jordan", tz: "Asia/Amman" },
  { label: "THR", city: "Tehran", country: "IR", countryName: "Iran", tz: "Asia/Tehran" },
  { label: "KHI", city: "Karachi", country: "PK", countryName: "Pakistan", tz: "Asia/Karachi" },
  { label: "LHE", city: "Lahore", country: "PK", countryName: "Pakistan", tz: "Asia/Karachi" },
  { label: "ISB", city: "Islamabad", country: "PK", countryName: "Pakistan", tz: "Asia/Karachi" },
  { label: "BOM", city: "Mumbai", country: "IN", countryName: "India", tz: "Asia/Kolkata" },
  { label: "DEL", city: "New Delhi", country: "IN", countryName: "India", tz: "Asia/Kolkata" },
  { label: "BLR", city: "Bengaluru", country: "IN", countryName: "India", tz: "Asia/Kolkata" },
  { label: "DAC", city: "Dhaka", country: "BD", countryName: "Bangladesh", tz: "Asia/Dhaka" },
  { label: "BKK", city: "Bangkok", country: "TH", countryName: "Thailand", tz: "Asia/Bangkok" },
  { label: "SIN", city: "Singapore", country: "SG", countryName: "Singapore", tz: "Asia/Singapore" },
  { label: "KUL", city: "Kuala Lumpur", country: "MY", countryName: "Malaysia", tz: "Asia/Kuala_Lumpur" },
  { label: "CGK", city: "Jakarta", country: "ID", countryName: "Indonesia", tz: "Asia/Jakarta" },
  { label: "MNL", city: "Manila", country: "PH", countryName: "Philippines", tz: "Asia/Manila" },
  { label: "HKG", city: "Hong Kong", country: "HK", countryName: "Hong Kong China", tz: "Asia/Hong_Kong" },
  { label: "SHA", city: "Shanghai", country: "CN", countryName: "China", tz: "Asia/Shanghai" },
  { label: "PEK", city: "Beijing", country: "CN", countryName: "China", tz: "Asia/Shanghai" },
  { label: "TPE", city: "Taipei", country: "TW", countryName: "Taiwan", tz: "Asia/Taipei" },
  { label: "ICN", city: "Seoul", country: "KR", countryName: "South Korea", tz: "Asia/Seoul" },
  { label: "TYO", city: "Tokyo", country: "JP", countryName: "Japan", tz: "Asia/Tokyo" },
  { label: "OSA", city: "Osaka", country: "JP", countryName: "Japan", tz: "Asia/Tokyo" },
  { label: "PER", city: "Perth", country: "AU", countryName: "Australia", tz: "Australia/Perth" },
  { label: "SYD", city: "Sydney", country: "AU", countryName: "Australia", tz: "Australia/Sydney" },
  { label: "MEL", city: "Melbourne", country: "AU", countryName: "Australia", tz: "Australia/Melbourne" },
  { label: "AKL", city: "Auckland", country: "NZ", countryName: "New Zealand", tz: "Pacific/Auckland" },
  { label: "UTC", city: "UTC", country: "UTC", countryName: "Universal Time", tz: "Etc/UTC" }
]

var LEGACY_TZ_COUNTRIES = {
  "US/Hawaii": "US",
  "US/Alaska": "US",
  "US/Pacific": "US",
  "US/Mountain": "US",
  "US/Central": "US",
  "US/Eastern": "US",
  "US/Arizona": "US"
}

function deriveCode(cityName) {
  var clean = String(cityName || "").replace(/[^A-Za-z]/g, "").toUpperCase()
  if (clean.length >= 3) return clean.slice(0, 3)
  return (clean + "XXX").slice(0, 3)
}

function cityDisplayName(label, tz, fallbackCity) {
  var code = String(label || "").toUpperCase()
  for (var i = 0; i < CURATED_CITIES.length; i++) {
    if (CURATED_CITIES[i].label === code && CURATED_CITIES[i].tz === tz) {
      return CURATED_CITIES[i].city
    }
  }
  for (var j = 0; j < CURATED_CITIES.length; j++) {
    if (CURATED_CITIES[j].tz === tz) {
      return CURATED_CITIES[j].city
    }
  }
  return fallbackCity || String(tz || "").split("/").pop().replace(/_/g, " ")
}

function countryForZone(label, tz, tzCountryMap) {
  var code = String(label || "").toUpperCase()
  for (var i = 0; i < CURATED_CITIES.length; i++) {
    if (CURATED_CITIES[i].label === code && CURATED_CITIES[i].tz === tz) {
      return CURATED_CITIES[i].country
    }
  }
  if (tzCountryMap && tzCountryMap[tz]) {
    var entry = String(tzCountryMap[tz])
    return entry.split("|")[0]
  }
  if (LEGACY_TZ_COUNTRIES[tz]) {
    return LEGACY_TZ_COUNTRIES[tz]
  }
  for (var j = 0; j < CURATED_CITIES.length; j++) {
    if (CURATED_CITIES[j].tz === tz) {
      return CURATED_CITIES[j].country
    }
  }
  var parts = String(tz || "").split("/")
  return parts.length > 1 ? parts[0].slice(0, 2).toUpperCase() : "GL"
}

// Formats as compact "CC/City" (e.g. "PK/Karachi", "IQ/Baghdad", "US/Los Angeles")
function countryCityDisplay(label, tz, fallbackCity, tzCountryMap) {
  var city = cityDisplayName(label, tz, fallbackCity)
  var country = countryForZone(label, tz, tzCountryMap)
  return country + "/" + city
}

function searchCities(query, ianaList, tzCountryMap) {
  var q = String(query || "").trim().toLowerCase()
  if (q.length === 0) {
    var defaults = []
    var topIndices = [0, 22, 50, 52, 62, 56, 79, 11]
    for (var d = 0; d < topIndices.length; d++) {
      var item = CURATED_CITIES[topIndices[d]]
      if (item) {
        defaults.push({
          label: item.label,
          name: item.city + " (" + item.label + ")",
          description: item.country + "/" + item.city,
          tz: item.tz
        })
      }
    }
    return defaults.slice(0, 6)
  }

  var scored = []
  var seenKey = {}

  for (var i = 0; i < CURATED_CITIES.length; i++) {
    var c = CURATED_CITIES[i]
    var lbl = c.label.toLowerCase()
    var cty = c.city.toLowerCase()
    var cc = c.country.toLowerCase()
    var cnt = c.countryName.toLowerCase()
    var tzLower = c.tz.toLowerCase()
    var ccPair = (c.country + "/" + c.city).toLowerCase()

    var score = -1
    if (lbl === q || cty === q || cc === q) score = 100
    else if (lbl.indexOf(q) === 0) score = 90
    else if (cty.indexOf(q) === 0) score = 85
    else if (cty.indexOf(q) !== -1) score = 70
    else if (cnt.indexOf(q) === 0 || ccPair.indexOf(q) === 0) score = 65
    else if (tzLower.indexOf(q) !== -1 || cnt.indexOf(q) !== -1 || ccPair.indexOf(q) !== -1) score = 50

    if (score > 0) {
      var k = c.label + "|" + c.tz
      seenKey[k] = true
      scored.push({
        score: score,
        label: c.label,
        name: c.city + " (" + c.label + ")",
        description: c.country + "/" + c.city,
        tz: c.tz
      })
    }
  }

  if (Array.isArray(ianaList)) {
    for (var j = 0; j < ianaList.length; j++) {
      var zone = String(ianaList[j] || "").trim()
      if (!zone || zone.indexOf("/") === -1) continue

      var parts = zone.split("/")
      var leaf = parts[parts.length - 1].replace(/_/g, " ")
      var rawEntry = (tzCountryMap && tzCountryMap[zone]) ? String(tzCountryMap[zone]) : ""
      var countryAbbr = countryForZone("", zone, tzCountryMap)
      var countryCity = countryAbbr + "/" + leaf
      var searchTarget = (zone + " " + countryCity + " " + rawEntry).toLowerCase()
      if (searchTarget.indexOf(q) === -1) continue

      var code = deriveCode(leaf)
      var key = code + "|" + zone
      if (seenKey[key]) continue
      seenKey[key] = true

      var zScore = leaf.toLowerCase().indexOf(q) === 0
        ? 75
        : (rawEntry.toLowerCase().indexOf(q) !== -1 ? 60 : 40)
      scored.push({
        score: zScore,
        label: code,
        name: leaf + " (" + code + ")",
        description: countryCity,
        tz: zone
      })
    }
  }

  scored.sort(function(a, b) {
    if (b.score !== a.score) return b.score - a.score
    return a.name.localeCompare(b.name)
  })

  return scored.slice(0, 6)
}
