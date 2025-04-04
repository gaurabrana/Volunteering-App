import 'package:flutter/material.dart';

import '../../../DataAccessLayer/TeamDAO.dart';

class TeamInputField extends StatefulWidget {
  final Function(String) updateSelectedTeamName;

  TeamInputField({required this.updateSelectedTeamName});

  @override
  State<StatefulWidget> createState() => TeamInputFieldState();
}

class TeamInputFieldState extends State<TeamInputField> {
  String _selectedTeam = "- Select team - ";
  List<String> _teamNames = ["- Select team - "];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTeams();
  }

  Future<void> _fetchTeams() async {
    try {
      final teamNames = await TeamDAO.getAllTeamNames();
      setState(() {
        _teamNames.addAll(teamNames.toSet().toList());
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching teams: $e');
    }
  }

  String getSelectedTeam() {
    return _selectedTeam;
  }

  @override
  Widget build(context) {
    return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 0.5,
              blurRadius: 10,
              offset: const Offset(2, 3),
            ),
          ],
        ),
        child: _isLoading
            ? CircularProgressIndicator() // Show a loading indicator while fetching teams
            : DropdownButtonFormField<String>(
                value: _selectedTeam,
                items: _teamNames.map((teamName) {
                  return DropdownMenuItem(
                    value: teamName,
                    child: Text(teamName),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _selectedTeam = value!;
                    widget.updateSelectedTeamName(value);
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Team',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                  ),
                  prefixIcon: Icon(
                    Icons.people,
                    color: Colors.grey,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                    borderSide: BorderSide.none,
                  ),
                ),
                isExpanded: true,
                validator: (value) {
                  if (value == null || value.isEmpty || value == "- Select team - ") {
                    return 'Please select a team';
                  }
                  return null;
                },
              ));
  }
}
