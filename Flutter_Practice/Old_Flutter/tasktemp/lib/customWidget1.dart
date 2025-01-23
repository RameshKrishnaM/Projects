import 'package:flutter/material.dart';

mycard(
  BuildContext context, {
  required String img,
  required String bname,
  required String prize,
}) {
  return SizedBox(
    height: 300,
    width: 230,
    child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20.0), // Adjust the radius as needed
              topRight: Radius.circular(20.0), // Adjust the radius as needed
            ),
            child: Image.asset(
              img,
              height: MediaQuery.of(context).size.height * 0.23,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  bname,
                  style: const TextStyle(
                    fontSize: 10.0,
                    color: Color(0xFF5A5A5A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  prize,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 10.0,
                    color: Color(0xFF4783B5),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 12.0,
                  color: Color(0xFFA1A1A1),
                ),
                SizedBox(
                  width: 2.0,
                ),
                Text(
                  'Sydney,Australia',
                  style: TextStyle(
                    fontSize: 10.0,
                    color: Color(0xFFA1A1A1),
                  ),
                )
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.zoom_out_map_rounded,
                  size: 12.0,
                  color: Color(0xFFA1A1A1),
                ),
                SizedBox(
                  width: 2.0,
                ),
                Text(
                  '3200 sqft',
                  style: TextStyle(
                    fontSize: 10.0,
                    color: Color(0xFFA1A1A1),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

mycard1(
  BuildContext context, {
  required String img,
}) {
  return Padding(
    padding: const EdgeInsets.only(left: 8.0),
    child: ClipRRect(
      borderRadius: const BorderRadius.all(
          Radius.circular(15.0) // Adjust the radius as needed
          ),
      child: Image.asset(
        img,
        height: 80,
        width: 80,
        fit: BoxFit.cover,
      ),
    ),
  );
}

cardIcon(BuildContext context, {required IconData iconData}) {
  return SizedBox(
    height: 80,
    width: 80,
    child: Card(
      color: const Color(0xFFF1F5FB),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(15.0),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(
            iconData,
            color: const Color(0xFF6887FD),
            size: 18.0,
          ),
          const Text(
            '3 bed',
            style: TextStyle(
                color: Color(0xFF5872C9),
                fontSize: 13.0,
                fontWeight: FontWeight.w700),
          )
        ],
      ),
    ),
  );
}
