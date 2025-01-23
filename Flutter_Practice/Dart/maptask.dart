void main() {
  Map<String, dynamic> data = {
    "CASH": {
      "segement": "CASH",
      "exchange": [
        {"exchangeid": "1", "exchangename": "NSE"},
        {"exchangeid": "10", "exchangename": "MCX"}
      ],
      "userstatus": "Y",
      "selected": "Y"
    },
    "COMMODITY": {
      "segement": "COMMODITY",
      "exchange": [
        {"exchangeid": "3", "exchangename": "MCX"},
        {"exchangeid": "8", "exchangename": "NSE"},
        {"exchangeid": "9", "exchangename": "BSE"}
      ],
      "userstatus": "Y",
      "selected": "Y"
    },
    "CURRENCY": {
      "segement": "CURRENCY",
      "exchange": [
        {"exchangeid": "2", "exchangename": "BSE"},
        {"exchangeid": "5", "exchangename": "NSE"}
      ],
      "userstatus": "Y",
      "selected": "Y"
    },
    "FUTURE AND OPTIONS": {
      "segement": "FUTURE AND OPTIONS",
      "exchange": [
        {"exchangeid": "4", "exchangename": "MCX"},
        {"exchangeid": "6", "exchangename": "BSE"},
        {"exchangeid": "7", "exchangename": "NSE"}
      ],
      "userstatus": "Y",
      "selected": "Y"
    }
  };

  List<String> selectedTiles = ["CASH", "FUTURE AND OPTIONS"];

  for (var key in data.keys) {
    if (!selectedTiles.contains(key)) {
      data[key]["selected"] = "N";
    }
  }

  print(data);
}
