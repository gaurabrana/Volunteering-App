import 'package:flutter/material.dart';

enum UserRole { admin, user, organisation }

class UserRoleFormField extends StatefulWidget {
  final Function(String) onChange;
  const UserRoleFormField({super.key, required this.onChange});

  @override
  _UserRoleFormFieldState createState() => _UserRoleFormFieldState();
}

class _UserRoleFormFieldState extends State<UserRoleFormField> {  
  UserRole? _selectedRole;

  // Filter out 'admin' role
  List<UserRole> get _dropdownRoles =>
      UserRole.values.where((role) => role != UserRole.admin).toList();

  @override
  Widget build(BuildContext context) {
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: DropdownButtonFormField<UserRole>(
          decoration: InputDecoration(
            hintText: 'Select Role',
            hintStyle: TextStyle(
              color: Colors.grey,
            ),
            prefixIcon: Icon(
              Icons.person,
              color: Colors.grey,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(25.0)),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade500, width: 2.0),
              borderRadius: BorderRadius.circular(25.0),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25.0),
              borderSide: BorderSide(
                color: Colors.red.shade700,
                width: 2.0,
              ),
            ),
          ),
          value: _selectedRole,
          onChanged: (UserRole? newValue) {
            setState(() {
              _selectedRole = newValue;
            });
            widget.onChange(newValue!.name);
          },
          validator: (value) => value == null ? 'Please select a role' : null,
          items: _dropdownRoles.map((UserRole role) {
            return DropdownMenuItem<UserRole>(
              value: role,
              child: Text(role.name.toUpperCase()), // or format nicely
            );
          }).toList(),
        ),
      ),
    );
  }
}
