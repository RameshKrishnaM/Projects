List logindata = [
  {'User Id': 'ramesh', 'password': '12345', 'role': 'Biller'},
  {'User Id': 'krishna', 'password': '12345', 'role': 'Manager'},
  {'User Id': 'kumar', 'password': '12345', 'role': 'Inventory'},
  {'User Id': 'krish', 'password': '12345', 'role': 'System Admin'},
];

List medicineMasterList = [
  {'Medicine Name': 'Med1', 'Brand': 'brand1'},
  {'Medicine Name': 'Med2', 'Brand': 'brand2'},
  {'Medicine Name': 'Med3', 'Brand': 'brand3'},
  {'Medicine Name': 'Med4', 'Brand': 'brand4'},
  {'Medicine Name': 'Med5', 'Brand': 'brand5'},
  {'Medicine Name': 'Med6', 'Brand': 'brand6'},
  {'Medicine Name': 'Med7', 'Brand': 'brand7'},
  {'Medicine Name': 'Med8', 'Brand': 'brand8'},
  {'Medicine Name': 'Med9', 'Brand': 'brand9'},
  {'Medicine Name': 'Med10', 'Brand': 'brand10'},
];
List stockList = [
  {'Medicine Name': 'Med1', 'quantity': '20', 'Unit Price': '21'},
  {'Medicine Name': 'Med2', 'quantity': '24', 'Unit Price': '54'},
  {'Medicine Name': 'Med3', 'quantity': '13', 'Unit Price': '65'},
  {'Medicine Name': 'Med4', 'quantity': '46', 'Unit Price': '12'},
  {'Medicine Name': 'Med5', 'quantity': '43', 'Unit Price': '45'},
  {'Medicine Name': 'Med6', 'quantity': '54', 'Unit Price': '78'},
  {'Medicine Name': 'Med7', 'quantity': '87', 'Unit Price': '23'},
  {'Medicine Name': 'Med8', 'quantity': '21', 'Unit Price': '26'},
  {'Medicine Name': 'Med9', 'quantity': '54', 'Unit Price': '28'},
  {'Medicine Name': 'Med10', 'quantity': '63', 'Unit Price': '65'},
];

List billformat = [
  {
    'Bill No ': '',
    'Bill Date ': '',
    'Bill Amount ': '',
    'Bill Gst ': '',
    'Net Price ': '',
    'User Id ': ''
  },
];

class BillItem {
  final String name;
  final String brand;
  final int quantity;
  final double unitPrice;

  BillItem(this.name, this.brand, this.quantity, this.unitPrice);

  double get amount => quantity * unitPrice;
}

class BillItemDetails {
  final String billno;
  final String billdate;
  final double amount;
  final double gst;
  final String id;

  BillItemDetails(this.billdate, this.amount, this.gst, this.id, this.billno);
  double get price => amount + gst;
}
