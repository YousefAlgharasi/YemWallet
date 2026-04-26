import 'package:flutter/material.dart';

import '../state/app_settings.dart';

class Contact {
  final String id;
  final String name;
  final String nameAr;
  final String handle;
  final String initials;
  final Color color;

  const Contact({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.handle,
    required this.initials,
    required this.color,
  });

  String localizedName(AppLang lang) => lang == AppLang.ar ? nameAr : name;
}

const kContacts = <Contact>[
  Contact(
    id: 'c1',
    name: 'Ahmed Al-Sabri',
    nameAr: 'أحمد الصبري',
    handle: '@ahmed.s',
    initials: 'AS',
    color: Color(0xFFFF7A45),
  ),
  Contact(
    id: 'c2',
    name: 'Layla Mahmoud',
    nameAr: 'ليلى محمود',
    handle: '@layla',
    initials: 'LM',
    color: Color(0xFF4D8AFF),
  ),
  Contact(
    id: 'c3',
    name: 'Salim Tahir',
    nameAr: 'سليم طاهر',
    handle: '@salim.t',
    initials: 'ST',
    color: Color(0xFF5FDBA0),
  ),
  Contact(
    id: 'c4',
    name: 'Nadia Al-Hakimi',
    nameAr: 'نادية الحكيمي',
    handle: '@nadia',
    initials: 'NA',
    color: Color(0xFFB39DFF),
  ),
  Contact(
    id: 'c5',
    name: 'Khalid Maktum',
    nameAr: 'خالد مكتوم',
    handle: '@khalid',
    initials: 'KM',
    color: Color(0xFFFFB84D),
  ),
];

Contact contactById(String id) => kContacts.firstWhere((c) => c.id == id);