import 'package:flutter/material.dart';

alertbox(context, {required String boxName, required Map user}) {
  return AlertDialog(
    content: boxName == 'Personal Details'
        ? SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('User Name  : ${user['username']}'),
                Text('Password   : ${user['password']}'),
                Text('Height     : ${user['height']}'),
                Text('weight     : ${user['weight']}'),
                Text('Eye Color  : ${user['eyeColor']}'),
                Text('Hair Color : ${user['hair']['color']}'),
                Text('Hair Type  : ${user['hair']['type']}'),
                Text('University  : ${user['university']}'),
                InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Address : \n${user['address']['address']},'),
                                Text('${user['address']['city']}'),
                                Text(
                                    '${user['address']['state']} - ${user['address']['postalCode']}'),
                                Text(
                                    'Co-Ordinates : \n Lat : ${user['address']['coordinates']['lat']} \n Long : ${user['address']['coordinates']['lng']} '),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Text(
                    'Address',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          )
        : boxName == 'Website Details'
            ? SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('Domain  : ${user['domain']}'),
                    Text('Ip Address  : ${user['ip']}'),
                    Text('Mac Address : ${user['macAddress']}'),
                  ],
                ),
              )
            : boxName == 'Bank Details'
                ? SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text('Card Number : ${user['bank']['cardNumber']}'),
                        Text('Card Type   : ${user['bank']['cardType']}'),
                        Text('Card Expiry : ${user['bank']['cardExpire']}'),
                        Text('Currency    : ${user['bank']['currency']}'),
                        Text('Iban : ${user['bank']['iban']}'),
                      ],
                    ),
                  )
                : SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text('Company Name : ${user['company']['name']}'),
                        Text('Title   : ${user['company']['title']}'),
                        Text('Role     : ${user['company']['department']}'),
                        Text('EIN     : ${user['ein']}'),
                        Text('SSN  : ${user['ssn']}'),
                        InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  content: SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            'Address : \n${user['company']['address']['address']},'),
                                        Text(
                                            '${user['company']['address']['city']}'),
                                        Text(
                                            '${user['company']['address']['state']} - ${user['company']['address']['postalCode']}'),
                                        Text(
                                            'Co-Ordinates : \n Lat : ${user['company']['address']['coordinates']['lat']} \n Long : ${user['company']['address']['coordinates']['lng']} '),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: Text(
                            'Address ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text('User Agent : ${user['userAgent']}'),
                      ],
                    ),
                  ),
  );
}

addressBox(context, {required Map users}) {
  return AlertDialog(
    content: SizedBox(
      height: MediaQuery.of(context).size.height * 0.2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Address : \n${users['address']['address']},'),
          Text('${users['address']['city']}'),
          Text(
              '${users['address']['state']} - ${users['address']['postalCode']}'),
          Text(
              'Co-Ordinates : \n Lat : ${users['address']['coordinates']['lat']} \n Long : ${users['address']['coordinates']['lng']} '),
        ],
      ),
    ),
  );
}
