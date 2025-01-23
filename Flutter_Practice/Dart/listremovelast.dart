void main(List<String> args) {
  List brokerageData = [
    ["Equity", "NIL,ID:1", "N/A", "N/A", "N/A"],
    [
      "Commodity",
      "N/A",
      "NSE: 0.00325% ; BSE 0.00375%,ID:2",
      "18% On (Brokerage + Transaction Charges + SEBI Charges),ID:3",
      "N/A"
    ],
    [
      "Charges",
      "N/A",
      "N/A",
      "N/A",
      "0.015% Or Rs.1500 Per Crore On Buy Side Only,ID:4"
    ],
    [
      "Currency",
      "N/A",
      "N/A",
      "0.0625% On Sell Side (On Premium) , OPTION EXCISED 0.125%,ID:5",
      "N/A"
    ]
  ];

  List s = brokerageData[3][3].toString().split(',');
  print(s.getRange(0, s.length - 1));
}
