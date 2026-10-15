.pragma library

var CURATED_CITIES = [
  { label: "NYC", city: "New York", country: "United States", tz: "America/New_York" },
  { label: "WAS", city: "Washington DC", country: "United States", tz: "America/New_York" },
  { label: "BOS", city: "Boston", country: "United States", tz: "America/New_York" },
  { label: "MIA", city: "Miami", country: "United States", tz: "America/New_York" },
  { label: "ATL", city: "Atlanta", country: "United States", tz: "America/New_York" },
  { label: "CHI", city: "Chicago", country: "United States", tz: "America/Chicago" },
  { label: "DAL", city: "Dallas", country: "United States", tz: "America/Chicago" },
  { label: "HOU", city: "Houston", country: "United States", tz: "America/Chicago" },
  { label: "AUS", city: "Austin", country: "United States", tz: "America/Chicago" },
  { label: "DEN", city: "Denver", country: "United States", tz: "America/Denver" },
  { label: "PHX", city: "Phoenix", country: "United States", tz: "America/Phoenix" },
  { label: "SFO", city: "San Francisco", country: "United States", tz: "America/Los_Angeles" },
  { label: "LAX", city: "Los Angeles", country: "United States", tz: "America/Los_Angeles" },
  { label: "SEA", city: "Seattle", country: "United States", tz: "America/Los_Angeles" },
  { label: "YYZ", city: "Toronto", country: "Canada", tz: "America/Toronto" },
  { label: "YVR", city: "Vancouver", country: "Canada", tz: "America/Vancouver" },
  { label: "YUL", city: "Montreal", country: "Canada", tz: "America/Toronto" },
  { label: "MEX", city: "Mexico City", country: "Mexico", tz: "America/Mexico_City" },
  { label: "GRU", city: "Sao Paulo", country: "Brazil", tz: "America/Sao_Paulo" },
  { label: "EZE", city: "Buenos Aires", country: "Argentina", tz: "America/Argentina/Buenos_Aires" },
  { label: "LDN", city: "London", country: "United Kingdom", tz: "Europe/London" },
  { label: "DUB", city: "Dublin", country: "Ireland", tz: "Europe/Dublin" },
  { label: "LIS", city: "Lisbon", country: "Portugal", tz: "Europe/Lisbon" },
  { label: "PAR", city: "Paris", country: "France", tz: "Europe/Paris" },
  { label: "BER", city: "Berlin", country: "Germany", tz: "Europe/Berlin" },
  { label: "FRA", city: "Frankfurt", country: "Germany", tz: "Europe/Berlin" },
  { label: "MUC", city: "Munich", country: "Germany", tz: "Europe/Berlin" },
  { label: "AMS", city: "Amsterdam", country: "Netherlands", tz: "Europe/Amsterdam" },
  { label: "BRU", city: "Brussels", country: "Belgium", tz: "Europe/Brussels" },
  { label: "ZRH", city: "Zurich", country: "Switzerland", tz: "Europe/Zurich" },
  { label: "GVA", city: "Geneva", country: "Switzerland", tz: "Europe/Zurich" },
  { label: "MAD", city: "Madrid", country: "Spain", tz: "Europe/Madrid" },
  { label: "BCN", city: "Barcelona", country: "Spain", tz: "Europe/Madrid" },
  { label: "ROM", city: "Rome", country: "Italy", tz: "Europe/Rome" },
  { label: "MIL", city: "Milan", country: "Italy", tz: "Europe/Rome" },
  { label: "VIE", city: "Vienna", country: "Austria", tz: "Europe/Vienna" },
  { label: "STO", city: "Stockholm", country: "Sweden", tz: "Europe/Stockholm" },
  { label: "OSL", city: "Oslo", country: "Norway", tz: "Europe/Oslo" },
  { label: "CPH", city: "Copenhagen", country: "Denmark", tz: "Europe/Copenhagen" },
  { label: "WAW", city: "Warsaw", country: "Poland", tz: "Europe/Warsaw" },
  { label: "PRG", city: "Prague", country: "Czechia", tz: "Europe/Prague" },
  { label: "ATH", city: "Athens", country: "Greece", tz: "Europe/Athens" },
  { label: "IST", city: "Istanbul", country: "Turkey", tz: "Europe/Istanbul" },
  { label: "CAI", city: "Cairo", country: "Egypt", tz: "Africa/Cairo" },
  { label: "CMN", city: "Casablanca", country: "Morocco", tz: "Africa/Casablanca" },
  { label: "LOS", city: "Lagos", country: "Nigeria", tz: "Africa/Lagos" },
  { label: "NBO", city: "Nairobi", country: "Kenya", tz: "Africa/Nairobi" },
  { label: "JNB", city: "Johannesburg", country: "South Africa", tz: "Africa/Johannesburg" },
  { label: "DXB", city: "Dubai", country: "United Arab Emirates", tz: "Asia/Dubai" },
  { label: "AUH", city: "Abu Dhabi", country: "United Arab Emirates", tz: "Asia/Dubai" },
  { label: "RUH", city: "Riyadh", country: "Saudi Arabia", tz: "Asia/Riyadh" },
  { label: "JED", city: "Jeddah", country: "Saudi Arabia", tz: "Asia/Riyadh" },
  { label: "MKK", city: "Makkah", country: "Saudi Arabia", tz: "Asia/Riyadh" },
  { label: "MED", city: "Madinah", country: "Saudi Arabia", tz: "Asia/Riyadh" },
  { label: "DOH", city: "Doha", country: "Qatar", tz: "Asia/Qatar" },
  { label: "KWI", city: "Kuwait City", country: "Kuwait", tz: "Asia/Kuwait" },
  { label: "BAH", city: "Manama", country: "Bahrain", tz: "Asia/Bahrain" },
  { label: "MCT", city: "Muscat", country: "Oman", tz: "Asia/Muscat" },
  { label: "AMM", city: "Amman", country: "Jordan", tz: "Asia/Amman" },
  { label: "KHI", city: "Karachi", country: "Pakistan", tz: "Asia/Karachi" },
  { label: "LHE", city: "Lahore", country: "Pakistan", tz: "Asia/Karachi" },
  { label: "ISB", city: "Islamabad", country: "Pakistan", tz: "Asia/Karachi" },
  { label: "BOM", city: "Mumbai", country: "India", tz: "Asia/Kolkata" },
  { label: "DEL", city: "New Delhi", country: "India", tz: "Asia/Kolkata" },
  { label: "BLR", city: "Bengaluru", country: "India", tz: "Asia/Kolkata" },
  { label: "DAC", city: "Dhaka", country: "Bangladesh", tz: "Asia/Dhaka" },
  { label: "BKK", city: "Bangkok", country: "Thailand", tz: "Asia/Bangkok" },
  { label: "SIN", city: "Singapore", country: "Singapore", tz: "Asia/Singapore" },
  { label: "KUL", city: "Kuala Lumpur", country: "Malaysia", tz: "Asia/Kuala_Lumpur" },
  { label: "CGK", city: "Jakarta", country: "Indonesia", tz: "Asia/Jakarta" },
  { label: "MNL", city: "Manila", country: "Philippines", tz: "Asia/Manila" },
  { label: "HKG", city: "Hong Kong", country: "China", tz: "Asia/Hong_Kong" },
  { label: "SHA", city: "Shanghai", country: "China", tz: "Asia/Shanghai" },
  { label: "PEK", city: "Beijing", country: "China", tz: "Asia/Shanghai" },
  { label: "TPE", city: "Taipei", country: "Taiwan", tz: "Asia/Taipei" },
  { label: "ICN", city: "Seoul", country: "South Korea", tz: "Asia/Seoul" },
  { label: "TYO", city: "Tokyo", country: "Japan", tz: "Asia/Tokyo" },
  { label: "OSA", city: "Osaka", country: "Japan", tz: "Asia/Tokyo" },
  { label: "PER", city: "Perth", country: "Australia", tz: "Australia/Perth" },
  { label: "SYD", city: "Sydney", country: "Australia", tz: "Australia/Sydney" },
  { label: "MEL", city: "Melbourne", country: "Australia", tz: "Australia/Melbourne" },
  { label: "AKL", city: "Auckland", country: "New Zealand", tz: "Pacific/Auckland" },
  { label: "UTC", city: "UTC", country: "Universal Time", tz: "Etc/UTC" }
]

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

function searchCities(query, ianaList) {
  var q = String(query || "").trim().toLowerCase()
  if (q.length === 0) {
    // Return top default popular cities when search field is empty
    var defaults = []
    var topIndices = [0, 20, 48, 50, 59, 69, 76, 11]
    for (var d = 0; d < topIndices.length; d++) {
      var item = CURATED_CITIES[topIndices[d]]
      if (item) {
        defaults.push({
          label: item.label,
          name: item.city + " (" + item.label + ")",
          description: item.country + " · " + item.tz,
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
    var cnt = c.country.toLowerCase()
    var tzLower = c.tz.toLowerCase()

    var score = -1
    if (lbl === q || cty === q) score = 100
    else if (lbl.indexOf(q) === 0) score = 90
    else if (cty.indexOf(q) === 0) score = 85
    else if (cty.indexOf(q) !== -1) score = 70
    else if (cnt.indexOf(q) === 0) score = 60
    else if (tzLower.indexOf(q) !== -1 || cnt.indexOf(q) !== -1) score = 50

    if (score > 0) {
      var k = c.label + "|" + c.tz
      seenKey[k] = true
      scored.push({
        score: score,
        label: c.label,
        name: c.city + " (" + c.label + ")",
        description: c.country + " · " + c.tz,
        tz: c.tz
      })
    }
  }

  if (Array.isArray(ianaList)) {
    for (var j = 0; j < ianaList.length; j++) {
      var zone = String(ianaList[j] || "").trim()
      if (!zone || zone.indexOf("/") === -1) continue
      var zLower = zone.toLowerCase()
      if (zLower.indexOf(q) === -1) continue

      var parts = zone.split("/")
      var region = parts[0].replace(/_/g, " ")
      var leaf = parts[parts.length - 1].replace(/_/g, " ")
      var code = deriveCode(leaf)
      var key = code + "|" + zone
      if (seenKey[key]) continue
      seenKey[key] = true

      var zScore = leaf.toLowerCase().indexOf(q) === 0 ? 75 : 40
      scored.push({
        score: zScore,
        label: code,
        name: leaf + " (" + code + ")",
        description: region + " · " + zone,
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
