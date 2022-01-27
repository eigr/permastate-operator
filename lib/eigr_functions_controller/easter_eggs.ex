defmodule Eigr.FunctionsController.EasterEggs do
  @destiny [
    "alpha-centauri",
    "proxima-centauri",
    "sirius",
    "epsilon-eridani",
    "epsilon-indi-A",
    "tau-ceti",
    "luyten-star",
    "teegarden-star",
    "kapteyn-star",
    "wolf-424",
    "wolf-1061",
    "gliese-86",
    "gliese-687",
    "gliese-674",
    "gliese-876",
    "gliese-832",
    "groombridge-34A",
    "procyon",
    "ross-128",
    "lalande-21185",
    "luhman-16A",
    "hd-7924-cassiopeia",
    "hd-9446-triangulum",
    "hd-10647-eridanus",
    "hd-10180-hydrus",
    "hd-12661-aries",
    "hd-37124-taurus",
    "hd-40307-pictor",
    "hip-14810-aries",
    "hip-49067-sextans",
    "24-sextantis-sextans",
    "hd-47186-canis-major",
    "hd-68988-ursa-major",
    "hd-82943-hydra",
    "55-cancri-cancer",
    "ogle-tr-211-carina",
    "trappist-1",
    "gj-9066",
    "k2-18b",
    "k2-65",
    "k2-155",
    "k2-240",
    "theta-ursae-majoris",
    "upsilon-andromedae",
    "40-eridani-a",
    "andromeda",
    "lv-426",
    "lv-223",
    "kronos",
    "vulcano",
    "aldebaran",
    "alfa-177",
    "algeron-iv",
    "gallifrey",
    "magrathea",
    "arrakis",
    "caladan",
    "giedi-prime",
    "salusa-secundus",
    "al-dhanab",
    "bela-tegeuse",
    "ix",
    "iv-anbus",
    "corrin",
    "kaitan",
    "richese",
    "theilax",
    "wallach-ix",
    "coruscant",
    "dagobah",
    "tatooine",
    "hoth",
    "endor",
    "naboo",
    "kashyyyk",
    "yavin-4",
    "dantooine",
    "bespin",
    "klendathu",
    "gethen",
    "annares",
    "urras",
    "trantor",
    "terminus",
    "comporellon",
    "solaria",
    "melpomenia",
    "aurora",
    "vogsphere",
    "caprica",
    "kobol",
    "proclarush-taonas",
    "lantea",
    "centauri-prime",
    "minbar",
    "ego",
    "arda",
    "solaris",
    "mote-prime",
    "lusitania",
    "abydos",
    "aegis-7",
    "altair",
    "amador",
    "antares",
    "anacreon-a",
    "amador",
    "51-pegasi-b",
    "ansket-iv",
    "tala",
    "ealen-iv",
    "sanghelios",
    "svir",
    "valyanop",
    "zhoist",
    "arcadia",
    "dm-3-1123-b",
    "draetheus-v",
    "gao",
    "ghibalb",
    "maethrillian",
    "reach",
    "charum-hakkor",
    "path-kethona",
    "pandora"
  ]

  @distances %{
    "alpha-centauri" => "4.367 light-years",
    "proxima-centauri" => "4.246 light-years",
    "sirius" => "8.611 light-years",
    "epsilon-eridani" => "10.47 light-years",
    "epsilon-indi-A" => "4.367 light-years",
    "tau-ceti" => "11.9 light-years",
    "luyten-star" => "12.2 light-years",
    "teegarden-star" => "12.59 light-years",
    "kapteyn-star" => "12.75 light-years",
    "wolf-424" => "14.32 light-years",
    "wolf-1061" => "13.8 light-years",
    "gliese-86" => "35.9 light-years",
    "gliese-687" => "14.7 light-years",
    "gliese-674" => "14.8 light-years",
    "gliese-876" => "15.2 light-years",
    "gliese-832" => "16 light-years",
    "groombridge-34A" => "11.62 light-years",
    "procyon" => "11.45 light-years",
    "ross-128" => "10.89 light-years",
    "lalande-21185" => "8.307 light-years",
    "luhman-16A" => "6.517 light-years",
    "hd-7924-cassiopeia" => "55.5 light-years",
    "hd-9446-triangulum" => "170 light-years",
    "hd-10647-eridanus" => "57 light-years",
    "hd-10180-hydrus" => "127 light-years",
    "hd-12661-aries" => "121.2 light-years",
    "hd-37124-taurus" => "107.63 light-years",
    "hd-40307-pictor" => "44 light-years",
    "hip-14810-aries" => "340 light-years",
    "hd-47186-canis-major" => "8.6 light-years",
    "theta-ursae-majoris" => "44 light-years",
    "hd-82943-hydra" => "138 light-years",
    "55-cancri-cancer" => "40.12 light-years",
    "trappist-1" => "39.46 light-years",
    "gj-9066" => "14.6 light-years",
    "k2-155" => "200 light-years",
    "k2-18b" => "124 light-years",
    "upsilon-andromedae" => "44.26 light-years",
    "andromeda" => "2.537.000 light-years",
    "path-kethona" => "160.000 light-years",
    "vulcano" => "16 light-years",
    "40-eridani-a" => "16 light-years"
  }

  def get_space_travel_destiny, do: Enum.random(@destiny)

  def calculate_distance_from_earth(gate) do
    if(Map.has_key?(@distances, gate)) do
      @distances[gate]
    else
      "unknown"
    end
  end
end
