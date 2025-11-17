
import 'package:flutter/material.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final days = ["Segunda", "Terça", "Quarta", "Quinta", "Sexta", "Sábado"];

    final schedule = [
      {
        "time": "06:00 - 11:00",
        "program": "manha-da-tropical.jpeg",
        "locutor": "Wellingtom",
        "days": [0, 1, 2, 3, 4, 5]
      },
      {
        "time": "11:00 - 12:30",
        "program": "cidade-revista.png",
        "locutor": "Grasiela Melo",
        "days": [0, 1, 2, 3, 4]
      },
      {
        "time": "12:30 - 14:30",
        "program": "comando-95.png",
        "locutor": "Ketlin Pereira / Bethânia Machado",
        "days": [0, 1, 2, 3, 4]
      },
      {
        "time": "15:00 - 18:30",
        "program": "da-o-play.png",
        "locutor": "Moyza Mesquita",
        "days": [0, 1, 2, 3, 4]
      },
    ];

    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
    child: Table(
          border: TableBorder.all(color: Colors.grey),
          columnWidths: const {
            0: FixedColumnWidth(90), // horário
            1: FixedColumnWidth(90), // segunda
            2: FixedColumnWidth(90), // terça
            3: FixedColumnWidth(90), // quarta
            4: FixedColumnWidth(90), // quinta
            5: FixedColumnWidth(90), // sexta
            6: FixedColumnWidth(90), // sábado
             },
          children: [
            TableRow(
              children: [
                const TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Horário",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                ...days.map(
                      (day) => TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(day,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
            ...schedule.map((item) {
              return TableRow(
                children: [
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(item["time"] as String),
                    ),
                  ),
                  ...days.map((day) {
                    final dayIndex = days.indexOf(day);
                    final isScheduled =
                    (item["days"] as List<int>).contains(dayIndex);

                    return TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: isScheduled
                            ? Column(
                          children: [
                            Image.asset("assets/${item["program"]}",height: 80,),
                            Text("Locutor(a): ${item["locutor"]}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 12)),
                          ],
                        )
                            : const SizedBox.shrink(),
                      ),
                    );
                  }),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    ));
  }
}