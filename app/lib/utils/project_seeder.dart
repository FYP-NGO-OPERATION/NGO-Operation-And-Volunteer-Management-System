import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../services/cloudinary_service.dart';

class ProjectSeeder {
  static Future<void> seedAll() async {
    await _seedProject(
      projectNo: 1,
      folderPath: 'E:\\Fyp\\Project-01',
      title: 'Ramadan Ration Drive 2023',
      category: 'Ramadan Drive',
      description:
          'Our Ramadan Drive aimed to distribute food rations to deserving families so they can observe fasting with ease. We collected funds, purchased bulk food items, packed them systematically, and distributed them across various locations.',
      targetGoal: 'Distribute Ration Bags to Maximum Deserving Families',
      itemsNeeded: 'Flour, Rice, Sugar, Oil, Dates, Pulses',
      location: 'Various Locations',
      lat: 31.5204, // Defaulting to Lahore/Central
      lng: 74.3587,
      startDate: DateTime(2023, 3, 20),
      eventDate: DateTime(2023, 4, 20),
      endDate: DateTime(2023, 4, 20),
    );

    await _seedProject(
      projectNo: 2,
      folderPath: 'E:\\Fyp\\Project-02',
      title: 'Winter Drive 2023 (Multan)',
      category: 'Winter Drive',
      description:
          'Our primary objective was to reach out to the maximum number of underprivileged individuals during the winter season. The initiative involved collecting old winter clothes from various households, thoroughly washing and ironing them, carefully packing them, and distributing them to those in need across different locations in Multan.',
      targetGoal: 'Reaching Maximum People & Distributing Packed Clothes',
      itemsNeeded: 'Old Clothes, Jackets, Sweaters',
      location: 'Multan',
      lat: 30.1575,
      lng: 71.5249,
      startDate: DateTime(2023, 12, 1),
      eventDate: DateTime(2023, 12, 10),
      endDate: DateTime(2023, 12, 10),
    );

    await _seedProject(
      projectNo: 3,
      folderPath: 'E:\\Fyp\\Project-03',
      title: 'Winter Drive 2023 (Balochistan)',
      category: 'Winter Drive',
      description:
          'Due to the harsh conditions in Balochistan our team has decided to arrange some clothes for the people of the Khetran village. One of our member went to khetran to distribute clothes among them. Alhamdullilah we arrange 100 winter items for them.',
      targetGoal: 'Provide Winter Relief to Remote Communities',
      itemsNeeded: 'Blankets, Warm Clothes',
      location: 'Khetran, Balochistan',
      lat: 29.8966, // Khetran area approx
      lng: 69.5262,
      startDate: DateTime(2023, 12, 1),
      eventDate: DateTime(2023, 12, 12),
      endDate: DateTime(2023, 12, 12),
    );

    await _seedProject(
      projectNo: 4,
      folderPath: 'E:\\Fyp\\Project-04',
      title: 'Medical Camp & Winter Drive 2023 (Sinawan)',
      category: 'Winter Drive',
      description:
          'A madrassah from Qasba Gurmani contact us and inform us that due to the limited resources of health their children are continuously being effected by it. Our team decided to arrange a free medical camp at 2 places one at madrassah and one at school. We also arrange jackets, socks, jersey, gloves and other winter articles for the children of madrassah. We gave free medicines to more than 900 people.',
      targetGoal: 'Provide Medical Relief and Winter Clothing',
      itemsNeeded: 'Medicines, Jackets, Socks, Gloves',
      location: 'Sinawan, Qasba Gurmani',
      lat: 30.3475,
      lng: 70.9632,
      startDate: DateTime(2023, 12, 1),
      eventDate: DateTime(2023, 12, 30),
      endDate: DateTime(2023, 12, 30),
    );

    await _seedProject(
      projectNo: 5,
      folderPath: 'E:\\Fyp\\Project-05',
      title: 'Carpets for Madrassah 1 2024',
      category: 'Masjid & Madrassah Support Drive',
      description:
          'A Lilbinat Madrassah in which students are just sitting on floor. There were no carpets for them to sit on. Our team decided to provide carpets to them. We arrange six carpets for them so they can sit easily.',
      targetGoal: 'Provide Carpets for Students',
      itemsNeeded: 'Carpets',
      location: 'Street no 2, Muhammadi Muhala, Near 9 No, Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2024, 1, 1),
      eventDate: DateTime(2024, 1, 19), // Event was on 19 Jan
      endDate: DateTime(2024, 1, 19), // Event was on 19 Jan
      donations: 24000.0,
      expenses: 24000.0,
    );

    await _seedProject(
      projectNo: 6,
      folderPath: 'E:\\Fyp\\Project-06',
      title: 'Roadside Food Drive 2024',
      category: 'Food Drive',
      description:
          'We decided to pack and distribute Rice among the patients of Children Hospital Multan. We made 150 boxes and distribute them among the patients.',
      targetGoal: 'Distribute Food to Patients',
      itemsNeeded: 'Rice, Boxes, Spoons',
      location: 'Children Hospital Multan',
      lat: 30.1798, // Approx Multan
      lng: 71.4691, // Approx Multan
      startDate: DateTime(2024, 2, 1),
      eventDate: DateTime(2024, 2, 16),
      endDate: DateTime(2024, 2, 16),
      donations: 12000.0,
      expenses: 9500.0,
    );

    await _seedProject(
      projectNo: 7,
      folderPath: 'E:\\Fyp\\Project-07',
      title: 'Rashan Drive Case 1 2024',
      category: 'Rashan Drive',
      description:
          'We receive a case of a widow with her 4 children. She works as a maid in different houses. She has a upper portion on rent and needed help in rashan. Our team decided to provide them rashan.',
      targetGoal: 'Provide Rashan to Widow Family',
      itemsNeeded: 'Flour, Sugar, Ghee, Rice, Groceries',
      location: 'Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2024, 2, 1),
      eventDate: DateTime(2024, 2, 18),
      endDate: DateTime(2024, 2, 18),
      donations: 6400.0,
      expenses: 6410.0,
    );

    await _seedProject(
      projectNo: 8,
      folderPath: 'E:\\Fyp\\Project-08',
      title: 'School Uniforms Case 1 2024',
      category: 'Education Drive',
      description:
          'There are 5 students whose families were not be able to provide them the uniforms. Our team purchased the uniforms for them and deleiver them.',
      targetGoal: 'Provide School Uniforms',
      itemsNeeded: 'School Uniforms (Boys & Girls)',
      location: 'Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2024, 2, 15),
      eventDate: DateTime(2024, 2, 25),
      endDate: DateTime(2024, 2, 25),
      donations: 6010.0,
      expenses: 6000.0,
    );

    await _seedProject(
      projectNo: 9,
      folderPath: 'E:\\Fyp\\Project-09',
      title: 'Ramadan Iftar Dastarkhan 2024',
      category: 'Ramadan Drive',
      description:
          'As the month of ramazan is coming. Our team decided to arrange a weekly iftar dastarkhan at Nishter Hospital Multan. Alhamdullilah we serve more than 900 persons per iftar.',
      targetGoal: 'Provide Iftar to Deserving People at Hospital',
      itemsNeeded: 'Food, Dates, Juices, Dastarkhan, Plates',
      location: 'Nishter Hospital Multan',
      lat: 30.1983, // Approx Nishter Multan
      lng: 71.4395, // Approx Nishter Multan
      startDate: DateTime(2024, 3, 11), // 1st Ramadan 2024
      eventDate: DateTime(2024, 4, 9), // End of Ramadan 2024 (approx)
      endDate: DateTime(2024, 4, 9), // End of Ramadan 2024 (approx)
      donations: 147390.0,
      expenses: 147890.0, // Week 1 (38640) + Week 2 (44250) + Week 3 (65000)
    );

    await _seedProject(
      projectNo: 10,
      folderPath: 'E:\\Fyp\\Project-10',
      title: 'Eid-ul-Fitr Gifts 2024',
      category: 'Eid Drive',
      description:
          'In the last ashrah of Ramazan Kareem our team decided to give eidi cards and eid suits among the children. We almost made 62 cards of Rs.500 each and also arranged 75 clothes packets for children.',
      targetGoal: 'Distribute Eid Gifts & Clothes to Children',
      itemsNeeded: 'Eidi Cards, Eid Suits, Clothes Packets',
      location: 'Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2024, 4, 10), // Eid-ul-Fitr Day 1 (approx)
      eventDate: DateTime(2024, 4, 12), // 3rd Day of Eid
      endDate: DateTime(2024, 4, 12), // 3rd Day of Eid
      donations: 31000.0,
      expenses: 31000.0,
    );

    await _seedProject(
      projectNo: 11,
      folderPath: 'E:\\Fyp\\Project-11',
      title: 'Ramadan Roadside Iftar 2024',
      category: 'Ramadan Drive',
      description:
          'Our team decided to distribute a deg among the people on the road side. We made 120 boxes and distribute among the guards and underprivileged people. In addition we also distribute some clothes among the people.',
      targetGoal: 'Distribute Iftar to Roadside People',
      itemsNeeded: 'Deg, Boxes, Shoppers, Clothes',
      location: 'Chungi No. 9, Multan',
      lat: 30.2185, // Approx Chungi No. 9
      lng: 71.4700, // Approx Chungi No. 9
      startDate: DateTime(2024, 3, 11), // 1st Ramadan 2024
      eventDate: DateTime(2024, 4, 9), // 9 April 2024
      endDate: DateTime(2024, 4, 9), // 9 April 2024
      donations: 8500.0,
      expenses: 8580.0,
    );

    await _seedProject(
      projectNo: 12,
      folderPath: 'E:\\Fyp\\Project-12',
      title: 'Ramadan Rashan Case 2024',
      category: 'Ramadan Drive',
      description:
          'A family of 8 members contact us that they are not be able to afford the rashan due to the misfortunate situations. Our team decided to provide them with rashan so they can easily spend their eid.',
      targetGoal: 'Provide Rashan for Eid',
      itemsNeeded: 'Flour, Sugar, Ghee, Rice, Groceries',
      location: 'Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2024, 3, 11), // 1st Ramadan 2024
      eventDate: DateTime(2024, 4, 9), // 9 April 2024
      endDate: DateTime(2024, 4, 9), // 9 April 2024
      donations: 6000.0,
      expenses: 6000.0,
    );

    await _seedProject(
      projectNo: 13,
      folderPath: 'E:\\Fyp\\Project-13',
      title: 'Dowry Case 1 2024',
      category: 'Marriage Support Drive',
      description:
          'Two underprivileged families contact us to arrange some dowry items for their daughters. We purchase some clothes, dinner set, water sets and bedsheets for them.',
      targetGoal: 'Arrange Dowry Items for Brides',
      itemsNeeded: 'Clothes, Dinner Sets, Water Sets, Bedsheets',
      location: 'Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2024, 4, 15),
      eventDate: DateTime(2024, 4, 30),
      endDate: DateTime(2024, 4, 30),
      donations: 23200.0,
      expenses: 23200.0,
    );

    await _seedProject(
      projectNo: 14,
      folderPath: 'E:\\Fyp\\Project-14',
      title: 'Free Medical Camp 2024',
      category: 'Health & Medical Drive',
      description:
          'Our team decided to arrange a medical camp in Multan. In this regard, we collaborate with Malik Ahmad Hussain Dehar’s Foundation. Alhamdullilah we checked almost 220 patients.',
      targetGoal: 'Arrange Free Medical Camp & Checkups',
      itemsNeeded: 'Medicines, Sugar Strips, Thermometer, Cotton Roll',
      location: 'MPS Road, Multan',
      lat: 30.1444, // Approx MPS Road Multan
      lng: 71.4912, // Approx MPS Road Multan
      startDate: DateTime(2024, 5, 15),
      eventDate: DateTime(2024, 6, 2),
      endDate: DateTime(2024, 6, 2),
      donations: 19550.0,
      expenses: 19550.0,
    );

    await _seedProject(
      projectNo: 15,
      folderPath: 'E:\\Fyp\\Project-15',
      title: 'Rashan Drive Case 2 2024',
      category: 'Rashan Drive',
      description:
          'A family contact us that they are not be able to afford the rashan due to the misfortunate situations. Our team decided to provide them with rashan so some of their burden will be reduced.',
      targetGoal: 'Provide Rashan',
      itemsNeeded: 'Flour, Sugar, Ghee, Rice, Groceries',
      location: 'Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2024, 5, 1),
      eventDate: DateTime(2024, 5, 7),
      endDate: DateTime(2024, 5, 7),
      donations: 3320.0,
      expenses: 3320.0,
    );

    await _seedProject(
      projectNo: 16,
      folderPath: 'E:\\Fyp\\Project-16',
      title: 'Rashan Drive Case 3 2024',
      category: 'Rashan Drive',
      description:
          'A family contact us that they are not be able to afford the rashan due to the misfortunate situations. Our team decided to provide them with rashan so some of their burden will be reduced.',
      targetGoal: 'Provide Rashan',
      itemsNeeded: 'Flour, Sugar, Ghee, Rice, Groceries',
      location: 'Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2024, 5, 1),
      eventDate: DateTime(2024, 5, 13),
      endDate: DateTime(2024, 5, 13),
      donations: 5000.0,
      expenses: 5000.0,
    );

    await _seedProject(
      projectNo: 17,
      folderPath: 'E:\\Fyp\\Project-17',
      title: 'Eid-ul-Azha Qurbani 2024',
      category: 'Eid Drive',
      description:
          'On Eid ul Azha of 2024 our team purchases 3 goats. From their meat we prepared rice degs. After packing of rice, we distribute them among the patients of different hospitals.',
      targetGoal: 'Qurbani & Meat Distribution',
      itemsNeeded: 'Goats, Rice, Spices, Packing Material',
      location: 'Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2024, 5, 17), // ~1 Month before Eid
      eventDate: DateTime(2024, 6, 19), // 3rd day of Eid ul Azha 2024 (approx)
      endDate: DateTime(2024, 6, 19), // 3rd day of Eid ul Azha 2024 (approx)
      donations: 222885.0,
      expenses: 218180.0,
    );

    await _seedProject(
      projectNo: 18,
      folderPath: 'E:\\Fyp\\Project-18',
      title: 'Free Pots for Birds 2024',
      category: 'Animal Welfare Drive',
      description:
          'This summer sun is blazing at its peak. Due to this extreme hot weather, birds are dying everyday. Our team decided to distribute free clay pots among the people to save the life of birds. Alhamdullilah we arranged 100 pots and distribute them among the people.',
      targetGoal: 'Provide water pots for birds in summer',
      itemsNeeded: 'Clay Pots (100)',
      location: 'Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2024, 5, 1),
      eventDate: DateTime(2024, 5, 24),
      endDate: DateTime(2024, 5, 24),
      donations: 9000.0,
      expenses: 9000.0,
    );

    await _seedProject(
      projectNo: 19,
      folderPath: 'E:\\Fyp\\Project-19',
      title: 'Mehfil-e-Durood Shareef 2024',
      category: 'Religious & Spiritual Drive',
      description:
          'We decide to arrange a Mehfil e Durood Shareef. Our mission is to enhance the love of Allah Mighty and Hazrat Muhammad P.B.U.H. Alhamdullilah we arranged a successful mehfil.',
      targetGoal: 'Arrange a Spiritual Gathering',
      itemsNeeded: 'Arrangements, Food/Refreshments',
      location: 'Chungi No. 9, Multan',
      lat: 30.2185, // Approx Chungi No. 9
      lng: 71.4700, // Approx Chungi No. 9
      startDate: DateTime(2024, 6, 1),
      eventDate: DateTime(2024, 6, 23),
      endDate: DateTime(2024, 6, 23),
      donations: 7900.0,
      expenses: 7900.0,
    );

    await _seedProject(
      projectNo: 20,
      folderPath: 'E:\\Fyp\\Project-20',
      title: 'School Uniforms Case 2 2024',
      category: 'Education Drive',
      description:
          'Three needy students required uniforms for their new classes. Our team decided to purchase uniform for them so after vacations they can easily continue their study.',
      targetGoal: 'Provide Uniforms for Students',
      itemsNeeded: 'School Uniforms (3)',
      location: 'Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2024, 6, 15),
      eventDate: DateTime(2024, 6, 30),
      endDate: DateTime(2024, 6, 30),
      donations: 4250.0,
      expenses: 4000.0,
    );

    await _seedProject(
      projectNo: 21,
      folderPath: 'E:\\Fyp\\Project-21',
      title: 'Small Shop Startup Assistance 2024',
      category: 'Livelihood & Empowerment',
      description:
          'A needy family of 2 persons contact us to arrange some items for them so they can run their short shop. Our team decided to provide them the items.',
      targetGoal: 'Assist in starting a small shop',
      itemsNeeded: 'Chips, Papar, Biscuits, Other Items',
      location: 'Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2024, 7, 1),
      eventDate: DateTime(2024, 7, 10),
      endDate: DateTime(2024, 7, 10),
      donations: 13000.0,
      expenses: 13000.0,
    );

    await _seedProject(
      projectNo: 22,
      folderPath: 'E:\\Fyp\\Project-22',
      title: 'Muharram Sabeel 2024',
      category: 'Religious & Spiritual Drive',
      description:
          'In the month of Muharram, we decided to arrange a 3 day sabeel for Hazrat Imam Hussain A.S and also for the martyrs of Karbala. May Allah accept out little effort. Ameen.',
      targetGoal: 'Arrange a 3-day Sabeel (Drink Distribution)',
      itemsNeeded: 'Jam-e-Shirin, Sugar, Catering, Glasses, Ice',
      location: 'Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2024, 7, 1),
      eventDate: DateTime(2024, 7, 14),
      endDate: DateTime(2024, 7, 14),
      donations: 8700.0,
      expenses: 8700.0,
    );

    await _seedProject(
      projectNo: 23,
      folderPath: 'E:\\Fyp\\Project-23',
      title: 'Rashan Drive Case 4 2024',
      category: 'Rashan Drive',
      description:
          'Our team decided to provided rashan to 2 needy families. They are really deserving. One family also need some female clothes so we also provide them.',
      targetGoal: 'Provide Rashan and Clothes to 2 Families',
      itemsNeeded: 'Rashan items, Suits, Flour, Oil',
      location: 'Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2024, 7, 20),
      eventDate: DateTime(2024, 7, 25),
      endDate: DateTime(2024, 7, 25),
      donations: 15000.0,
      expenses: 15000.0,
    );

    await _seedProject(
      projectNo: 24,
      folderPath: 'E:\\Fyp\\Project-24',
      title: 'Carpets for Masjid 2024',
      category: 'Masjid & Madrassah Support Drive',
      description:
          'A Mosque management contact us for the purpose of carpets. Our team decided to provide them with carpets. May Allah accept our little effort. Ameen.',
      targetGoal: 'Provide Carpets for Masjid',
      itemsNeeded: 'Carpets, Steel Cooler',
      location: 'Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2024, 7, 20),
      eventDate: DateTime(2024, 7, 31),
      endDate: DateTime(2024, 7, 31),
      donations: 15050.0,
      expenses: 14000.0,
    );

    await _seedProject(
      projectNo: 25,
      folderPath: 'E:\\Fyp\\Project-25',
      title: '14 August Plantation Drive 2024',
      category: 'Environmental Drive',
      description:
          'On this 14 August our team decided to do plantation activity in Multan. Alhamdullilah we purchased 27 plants, and planted them near Vehari Chowk. May Allah almighty accept this little effort.',
      targetGoal: 'Plant Trees for 14th August',
      itemsNeeded: 'Plants (27), Gardener services',
      location: 'Vehari Chowk, Multan',
      lat: 30.1798, // Approx Vehari Chowk Multan
      lng: 71.4691, // Approx Vehari Chowk Multan
      startDate: DateTime(2024, 8, 1),
      eventDate: DateTime(2024, 8, 14),
      endDate: DateTime(2024, 8, 14),
      donations: 11500.0,
      expenses: 11500.0,
    );

    await _seedProject(
      projectNo: 26,
      folderPath: 'E:\\Fyp\\Project-26',
      title: 'Old Age Home Visit 2024',
      category: 'Social Welfare Drive',
      description:
          'Our Team decided to arrange a get together with the parents of old age home. We arrange lunch for them, after lunch we arrange a mehfil e milaad . After milaad we cut cake with them. At the end we spend time with them and gave Gajras to our mothers.',
      targetGoal: 'Spend time with elderly at Old Age Home',
      itemsNeeded: 'Cake, Lunch (Deg & Roti), Gajray, Tea, Milk',
      location: 'Afiyat Old Age Home, Shamsabad Colony, Multan',
      lat: 30.2030, // Approx Shamsabad Multan
      lng: 71.4580, // Approx Shamsabad Multan
      startDate: DateTime(2024, 9, 1),
      eventDate: DateTime(2024, 9, 17),
      endDate: DateTime(2024, 9, 17),
      donations: 26350.0,
      expenses: 22320.0,
    );

    await _seedProject(
      projectNo: 27,
      folderPath: 'E:\\Fyp\\Project-27',
      title: 'Dowry Case 2 2024',
      category: 'Marriage Support Drive',
      description:
          'Our team has decided to arrange dowry items for a bride. We arrange some clothes, shoes, abaya and some other items. May Allah bless us for this little effort. May Allah bless all the donors',
      targetGoal: 'Provide Dowry Items for a Bride',
      itemsNeeded: 'Clothes, Shoes, Abaya, Cooler, Steel Items',
      location: 'Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2024, 10, 1),
      eventDate: DateTime(2024, 10, 10),
      endDate: DateTime(2024, 10, 10),
      donations: 32540.0,
      expenses: 32540.0,
    );

    await _seedProject(
      projectNo: 28,
      folderPath: 'E:\\Fyp\\Project-28',
      title: 'Carpets for Madrassah 2 2024',
      category: 'Masjid & Madrassah Support Drive',
      description:
          'Our team has decided to arrange carpets, ruhail, Quran Majeed and other items for a madrassah. May Allah bless all the donors. May Allah accept all our efforts.',
      targetGoal: 'Provide Carpets and Items for Madrassah',
      itemsNeeded: 'Carpets, Ruhail, Quran Majeed, Chatai, Cooler, etc.',
      location: 'Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2024, 10, 4),
      eventDate: DateTime(2024, 10, 15),
      endDate: DateTime(2024, 10, 15),
      donations: 17170.0,
      expenses: 15520.0,
    );

    await _seedProject(
      projectNo: 29,
      folderPath: 'E:\\Fyp\\Project-29',
      title: 'Dowry Case 3 2024',
      category: 'Marriage Support Drive',
      description:
          'Our team has decided to arrange dowry items for 3 brides. We arrange some clothes, shoes, glass sets and some other items. May Allah bless us for this little effort. May Allah bless all the donors',
      targetGoal: 'Provide Dowry Items for 3 Brides',
      itemsNeeded: 'Clothes, Shoes, Glass Sets, Hotpot Sets, Water Sets',
      location: 'Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2024, 10, 14),
      eventDate: DateTime(2024, 11, 15),
      endDate: DateTime(2024, 11, 15),
      donations: 28050.0,
      expenses: 27200.0,
    );

    await _seedProject(
      projectNo: 30,
      folderPath: 'E:\\Fyp\\Project-30',
      title: 'Winter Drive 2024',
      category: 'Winter Drive',
      description:
          'As the winter arrives in Multan our team decides to collect clothes for the underprivileged families. Our team take some quick actions for the collection of clothes and offered free clothes pick up service. We collect clothes, press them and pack them in a kind manner. Alhamdullilah we collected clothes for 130 families.',
      targetGoal: 'Collect Winter Clothes for Underprivileged',
      itemsNeeded:
          'Packing Shoppers, Donation Receipts, Stickers, Certificates',
      location: 'Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2024, 12, 1),
      eventDate: DateTime(2024, 12, 8),
      endDate: DateTime(2024, 12, 8),
      donations: 4150.0,
      expenses: 3240.0,
    );

    await _seedProject(
      projectNo: 31,
      folderPath: 'E:\\Fyp\\Project-31',
      title: 'Dowry Case 4 2024',
      category: 'Marriage Support Drive',
      description:
          'A Widow contact us that her daughter marriage is near and she needed help in arranging furniture. Alhamdullilah by the help of Allah almighty we had arranged bed for the bride.',
      targetGoal: 'Arrange Bed for a Bride',
      itemsNeeded: 'Bed',
      location: 'Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2024, 12, 1),
      eventDate: DateTime(2024, 12, 7),
      endDate: DateTime(2024, 12, 7),
      donations: 7500.0,
      expenses: 7500.0,
    );

    await _seedProject(
      projectNo: 32,
      folderPath: 'E:\\Fyp\\Project-32',
      title: 'Rashan Drive Case 5 2024',
      category: 'Rashan Drive',
      description:
          'One needy family contact us to gave them rashan. Alhamdullilah we collect the donation and provide them with rashan. May Allah Almighty accept our little effort.',
      targetGoal: 'Provide Rashan for a Needy Family',
      itemsNeeded: 'Flour, Sunlight, Daal, Sugar, Oil, Rice, Vegetables, etc.',
      location: 'Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2024, 12, 10),
      eventDate: DateTime(2024, 12, 16),
      endDate: DateTime(2024, 12, 16),
      donations: 5000.0,
      expenses: 5000.0,
    );

    await _seedProject(
      projectNo: 33,
      folderPath: 'E:\\Fyp\\Project-33',
      title: 'House Rent Case 1 2024',
      category: 'Financial Assistance Drive',
      description:
          'A needy family of 5 people contact us. They are struggling to pay their house rent. Our team decide to pay the rent of 3 Months.',
      targetGoal: 'Pay 3 Months House Rent for a Needy Family',
      itemsNeeded: 'Cash for Rent',
      location: 'Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2024, 12, 15),
      eventDate: DateTime(2024, 12, 26),
      endDate: DateTime(2024, 12, 26),
      donations: 13500.0,
      expenses: 13500.0,
    );

    await _seedProject(
      projectNo: 34,
      folderPath: 'E:\\Fyp\\Project-34',
      title: 'House Rent Case 2 2025',
      category: 'Financial Assistance Drive',
      description:
          'A divorced female who is also the care taker of her children and parents, contact us to help her in the rent. After verification we decided to help her in her rent. Alhamdullilah we pay her half rent.',
      targetGoal: 'Provide Half Rent for a Divorced Sister',
      itemsNeeded: 'Cash for Rent',
      location: 'Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2025, 2, 1),
      eventDate: DateTime(2025, 2, 7),
      endDate: DateTime(2025, 2, 7),
      donations: 5000.0,
      expenses: 5000.0,
    );

    await _seedProject(
      projectNo: 35,
      folderPath: 'E:\\Fyp\\Project-35',
      title: 'Kot Addu Medical Camp 2025',
      category: 'Health & Medical Drive',
      description:
          'We decided to arrange a medical camp in Kot Addu. First we visit the place then we decide to arrange camp on 16 Feb 2025. Alhamdullilah we checked 200 patients and also distribute medicine.',
      targetGoal: 'Provide Free Medical Checkup and Medicines',
      itemsNeeded: 'Medicines, Certificates, Medical Supplies',
      location:
          'Basti Hajany wala Moza Talai Chandrarh Gharbi Near Lar Chowk, Kot Addu',
      lat: 30.4700, // Kot Addu approx
      lng: 70.9667, // Kot Addu approx
      startDate: DateTime(2025, 1, 1),
      eventDate: DateTime(2025, 2, 16),
      endDate: DateTime(2025, 2, 16),
      donations: 17310.0,
      expenses: 11810.0,
    );

    await _seedProject(
      projectNo: 36,
      folderPath: 'E:\\Fyp\\Project-36',
      title: 'Rashan Drive Case 6 2025',
      category: 'Rashan Drive',
      description:
          'A needy family contact us to arrange some rashan for them. We decided to help them out. Alhamdullilah we delivered them rashan. May Allah accept our little effort.',
      targetGoal: 'Provide Rashan for a Needy Family',
      itemsNeeded: 'Rashan, Sabzi, Groceries',
      location: 'Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2025, 2, 21),
      eventDate: DateTime(2025, 2, 25),
      endDate: DateTime(2025, 2, 25),
      donations: 6100.0,
      expenses: 6100.0,
    );

    await _seedProject(
      projectNo: 37,
      folderPath: 'E:\\Fyp\\Project-37',
      title: 'Weekly Iftar Dastarkhan 2025',
      category: 'Ramadan Drive',
      description:
          'This Ramzan we decided to arrange weekly iftar dastarkhan in Nishtar hospital. By the permission of MS Nishtar we arranged 4 weekly dastarkhan in Nishtar hospital. May Allah accept all our efforts.',
      targetGoal: 'Arrange 4 Weekly Iftar Dastarkhan in Ramadan',
      itemsNeeded:
          'Rice Deg, Catering, Sufrah, Sharbat, Sugar, Dates, Disposable Plates',
      location: 'Nishtar Hospital, Multan',
      lat: 30.2036, // Nishtar Hospital approx
      lng: 71.4429, // Nishtar Hospital approx
      startDate: DateTime(
        2025,
        1,
        28,
      ), // 1 month before Ramadan (approx donation start)
      eventDate: DateTime(2025, 3, 28), // Last Friday of Ramadan (approx)
      endDate: DateTime(2025, 3, 28), // Last Friday of Ramadan (approx)
      donations: 234432.0,
      expenses: 209770.0,
    );

    await _seedProject(
      projectNo: 38,
      folderPath: 'E:\\Fyp\\Project-38',
      title: 'Small Business Setup 2 2025',
      category: 'Livelihood & Empowerment',
      description:
          'A needy person contact us to help him out in arranging a small business. Alhamdullilah we help him out by providing him a small Samosa setup. May Allah accept our little effort.',
      targetGoal: 'Provide a small Samosa setup for livelihood',
      itemsNeeded: 'Samosay, Oil, Karahi',
      location: 'Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2025, 5, 1),
      eventDate: DateTime(2025, 5, 3),
      endDate: DateTime(2025, 5, 3),
      donations: 5000.0,
      expenses: 5000.0,
    );

    await _seedProject(
      projectNo: 39,
      folderPath: 'E:\\Fyp\\Project-39',
      title: 'Eid Cards & Gifts 2025',
      category: 'Eid Drive',
      description:
          'On this Eid-ul_fitr we distributed Eidi among needy children of Multan. We make unique eidi cards and than we distribute them among the children. May Allah accept our little effort.',
      targetGoal: 'Distribute Eidi, Clothes, and Gifts to needy children',
      itemsNeeded: 'Eid Cards, Female suits, Male suit',
      location: 'Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2025, 3, 25), // 25th Ramadan approx
      eventDate: DateTime(2025, 4, 2), // 3rd day of Eid approx
      endDate: DateTime(2025, 4, 2), // 3rd day of Eid approx
      donations: 24100.0,
      expenses: 23800.0,
    );

    await _seedProject(
      projectNo: 40,
      folderPath: 'E:\\Fyp\\Project-40',
      title: 'Blood Test & X-ray Case 2025',
      category: 'Health & Medical Drive',
      description:
          'A needy person contact us that his son is very ill and he urgently need some help in blood test and X-ray. We help him in the xray and blood test. May Allah accept our little effort.',
      targetGoal: 'Arrange money for blood test and x-ray for a needy child',
      itemsNeeded: 'Blood test, X-ray',
      location: 'Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2025, 4, 1),
      eventDate: DateTime(2025, 4, 10),
      endDate: DateTime(2025, 4, 10),
      donations: 2800.0,
      expenses: 2800.0,
    );

    await _seedProject(
      projectNo: 41,
      folderPath: 'E:\\Fyp\\Project-41',
      title: 'Palestine Awareness Event 2025',
      category: 'Awareness Drive',
      description:
          'We decide to distribute israel products poster among different stores so people can buycott the israeli product. Alhamdullilah we distribute more than 50 stickers in different locations.',
      targetGoal: 'Distribute stickers to promote boycott of Israeli products',
      itemsNeeded: 'Flag sticker, Products sticker',
      location: 'Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2025, 4, 1),
      eventDate: DateTime(2025, 4, 19),
      endDate: DateTime(2025, 4, 19),
      donations: 2500.0,
      expenses: 2500.0,
    );

    await _seedProject(
      projectNo: 42,
      folderPath: 'E:\\Fyp\\Project-42',
      title: 'Donation For Palestine 2025',
      category: 'Emergency Relief Drive',
      description:
          'Due to the extremely harsh conditions in Palestine we decided to collect donation for Gaza. With the help of Muslim Mission society we send some money towards Gaza. May Allah accept our little effort.',
      targetGoal:
          'Collect donation for Gaza and send via Muslim Mission Society',
      itemsNeeded: 'Cash send',
      location: 'Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2025, 5, 1),
      eventDate: DateTime(2025, 5, 11),
      endDate: DateTime(2025, 5, 11),
      donations: 32500.0,
      expenses: 32500.0,
    );

    await _seedProject(
      projectNo: 43,
      folderPath: 'E:\\Fyp\\Project-43',
      title: 'HMDC Free Medical Camp 2025',
      category: 'Health & Medical Drive',
      description:
          'Alhamdullilah by the grace of Allah Almighty we arranged a one day free medical camp in Humdard Orphanage Multan. In this camp we provide free check up and distributed free medicines.',
      targetGoal: 'Arrange a one day free medical camp for orphans',
      itemsNeeded:
          'Rice Deg, Disposable Box, Certificates, Stickers, Free Medicines',
      location: 'Humdard Orphanage, Gulshan e Mehr Colony, Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2025, 4, 7),
      eventDate: DateTime(2025, 5, 15),
      endDate: DateTime(2025, 5, 15),
      donations: 12200.0,
      expenses: 12200.0,
    );

    await _seedProject(
      projectNo: 44,
      folderPath: 'E:\\Fyp\\Project-44',
      title: 'Qurbani Event 2025',
      category: 'Qurbani Drive',
      description:
          'Continuing our tradition of last year, this year we also purchase goats to do Qurbani for needy people. We prepare rice from there meat and distribute them to the needy people. May Allah accept our little effort.',
      targetGoal:
          'Purchase goats, prepare meat and rice, and distribute to the needy on Eid-ul-Azha',
      itemsNeeded: 'Goats, Rice, Spices, Catering, Boxes',
      location: 'Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2025, 5, 7),
      eventDate: DateTime(2025, 6, 9),
      endDate: DateTime(2025, 6, 9),
      donations: 215850.0,
      expenses: 215850.0,
    );

    await _seedProject(
      projectNo: 45,
      folderPath: 'E:\\Fyp\\Project-45',
      title: 'Rashan Case 7 2025',
      category: 'Rashan Drive',
      description:
          'One needy family contact us that they need some help in Rashan. Alhamdullilah we deliver them with rashan. May Allah accept our little effort. May Allah bless all our donors. Ameen.',
      targetGoal: 'Provide rashan to a needy family',
      itemsNeeded: 'Flour, Oil, Rice, Pulses, Sugar, Milk, Tea, Spices',
      location: 'Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2025, 5, 12),
      eventDate: DateTime(2025, 5, 18),
      endDate: DateTime(2025, 5, 18),
      donations: 6170.0,
      expenses: 6170.0,
    );

    await _seedProject(
      projectNo: 46,
      folderPath: 'E:\\Fyp\\Project-46',
      title: 'Solar Cooler Case 2025',
      category: 'Summer Relief Drive',
      description:
          'A needy old women contact us that due the the harsh summer of Multan she is suffering from serious illness. We decided to provide them with a solar air cooler. May Allah accept our little effort.',
      targetGoal: 'Provide a solar cooler to a needy old woman',
      itemsNeeded: 'Cooler, Solar panel, Wire, Delivery, Electrician',
      location: 'Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2025, 5, 14),
      eventDate: DateTime(2025, 5, 18),
      endDate: DateTime(2025, 5, 18),
      donations: 34700.0,
      expenses: 34700.0,
    );

    await _seedProject(
      projectNo: 47,
      folderPath: 'E:\\Fyp\\Project-47',
      title: 'Medicine Case 2025',
      category: 'Health & Medical Drive',
      description:
          'A needy man contact us that his wife got a miscarriage due to this she required urgent medicine and oxygen support. We provided them with medicine, oxygen cylinder and nebulizer.',
      targetGoal:
          'Provide urgent medicine, oxygen, and nebulizer to a miscarriage patient',
      itemsNeeded: 'Medicine, Nebulizer mask, Oxygen Cylinder',
      location: 'Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2025, 6, 1),
      eventDate: DateTime(2025, 6, 10),
      endDate: DateTime(2025, 6, 10),
      donations: 6350.0,
      expenses: 3600.0,
    );

    await _seedProject(
      projectNo: 48,
      folderPath: 'E:\\Fyp\\Project-48',
      title: 'Mehfil-e-Durood Shareef 2025',
      category: 'Religious & Spiritual Drive',
      description:
          'Our team decided to arrange a Mehfil-e-Durood Sharif to make our soul blessed with the light of Islam. Alhamdullilah we also arranged food all the persons who join us in this mehfil.',
      targetGoal:
          'Arrange Mehfil-e-Durood Shareef and provide food for attendees',
      itemsNeeded: 'Food ingredients, Spices, Roti, Daig Pakwai',
      location: 'Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2025, 6, 20),
      eventDate: DateTime(2025, 6, 24),
      endDate: DateTime(2025, 6, 24),
      donations: 7090.0,
      expenses: 7090.0,
    );

    await _seedProject(
      projectNo: 49,
      folderPath: 'E:\\Fyp\\Project-49',
      title: 'Rent Case 3 2025',
      category: 'Financial Assistance Drive',
      description:
          'A needy maid contact us that due to high inflation she cannot be able to pay her current month house rent. Alhamdullilah we assist her in paying her house rent. May Allah accept our little effort. Ameen.',
      targetGoal: 'Assist a needy maid in paying her house rent',
      itemsNeeded: 'Rent payment',
      location: 'Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2025, 6, 22),
      eventDate: DateTime(2025, 6, 24),
      endDate: DateTime(2025, 6, 24),
      donations: 5000.0,
      expenses: 5000.0,
    );

    await _seedProject(
      projectNo: 50,
      folderPath: 'E:\\Fyp\\Project-50',
      title: 'Rashan Case 8 2025',
      category: 'Rashan Drive',
      description:
          'A needy family contact us that they need some help in rashan. Alhamdullilah we provide them with rashan. May Allah accept our little effort. May Allah bless all our donors. Ameen.',
      targetGoal: 'Provide rashan to a needy family',
      itemsNeeded: 'Flour, Oil, Rice, Spices, Sugar, Tea, Milk powder',
      location: 'Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2025, 6, 25),
      eventDate: DateTime(2025, 7, 1),
      endDate: DateTime(2025, 7, 1),
      donations: 3250.0,
      expenses: 3250.0,
    );

    await _seedProject(
      projectNo: 51,
      folderPath: 'E:\\Fyp\\Project-51',
      title: 'Clothes Case 2025',
      category: 'Clothing Drive',
      description:
          'A needy family contact us that they need some help in clothes and shoes. Alhamdullilah we provide them with these items. May Allah accept our little effort. May Allah bless all our donors. Ameen.',
      targetGoal: 'Provide clothes and shoes for a needy family',
      itemsNeeded: 'Female Suit, Female Shoes, Male Suit, Male Shoes',
      location: 'Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2025, 6, 28),
      eventDate: DateTime(2025, 7, 3),
      endDate: DateTime(2025, 7, 3),
      donations: 6200.0,
      expenses: 5000.0,
    );

    await _seedProject(
      projectNo: 52,
      folderPath: 'E:\\Fyp\\Project-52',
      title: 'Pots For Birds 2025',
      category: 'Animal Welfare Drive',
      description:
          'Due to the harsh summer in Multan, death rate of birds is increasing significantly. Due to this we decided to organize a stall for the free distribution of Clay Pots among the people. May Allah accept our little effort.',
      targetGoal:
          'Distribute free clay pots to provide water for birds during harsh summer',
      itemsNeeded: 'Clay Pots, Panaflex, Certificates, Pages',
      location: 'Chungi No. 9, Multan',
      lat: 30.2036, // Approximate for Chungi no 9 Multan, or default 30.1575
      lng:
          71.4687, // Approximate or default 71.5249. Let's stick to default or slightly adjust. I will use default for consistency unless specified.
      startDate: DateTime(2025, 6, 30),
      eventDate: DateTime(2025, 7, 5),
      endDate: DateTime(2025, 7, 5),
      donations: 12000.0,
      expenses: 12000.0,
    );

    await _seedProject(
      projectNo: 53,
      folderPath: 'E:\\Fyp\\Project-53',
      title: 'Road Side Food Purchase 1 2025',
      category: 'Food Drive',
      description:
          'Our team decided to purchase products from a local vendor. We decided to buy all the items from him and also make some extra payment to him so he can buy something for his house. May Allah accept our little effort. Ameen.',
      targetGoal:
          'Purchase food from a local street vendor to support them and distribute the food',
      itemsNeeded: 'Payment to Vendor',
      location: 'Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2025, 7, 4),
      eventDate: DateTime(2025, 7, 30),
      endDate: DateTime(2025, 7, 30),
      donations: 5400.0,
      expenses: 5000.0,
    );

    await _seedProject(
      projectNo: 54,
      folderPath: 'E:\\Fyp\\Project-54',
      title: 'Free Plants Distribution 1 2025',
      category: 'Environmental Drive',
      description:
          'On this 14 August, we decided to arrange a Free Plant Distribution Stall. Our aim is to make our Pakistan a better country. We will do anything to protect it. Alhamdullilah we distribute 40 plants among the people. May Allah Accept our effort.',
      targetGoal:
          'Arrange a Free Plant Distribution Stall on 14 August to promote a greener Pakistan',
      itemsNeeded:
          'Plants, Stickers, Panaflex, Certificates, Pages, Transport, Catering',
      location: 'Chungi No. 9, Multan',
      lat: 30.2036, // Approximate for Chungi no 9 Multan, or default 30.1575
      lng: 71.4687, // Approximate or default 71.5249.
      startDate: DateTime(2025, 8, 1),
      eventDate: DateTime(2025, 8, 14),
      endDate: DateTime(2025, 8, 14),
      donations: 10840.0,
      expenses: 10840.0,
    );

    await _seedProject(
      projectNo: 55,
      folderPath: 'E:\\Fyp\\Project-55',
      title: 'Ceiling Fan Case 2025',
      category: 'Summer Relief Drive',
      description:
          'A needy family contact us that due to the loss of their monthly salary, they sold their air cooler, due to this whole family is sleeping without any fan from the last 3 weeks. Alhamdullilah we provided them with Ceiling Fan.',
      targetGoal:
          'Provide a ceiling fan to a family suffering from summer heat',
      itemsNeeded:
          'Ceiling Fan, Electrician, Electric wire, Clip, 3 inch fan hook, Solution tape',
      location: 'Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2025, 8, 7),
      eventDate: DateTime(2025, 8, 20),
      endDate: DateTime(2025, 8, 20),
      donations: 8500.0,
      expenses: 8500.0,
    );

    await _seedProject(
      projectNo: 56,
      folderPath: 'E:\\Fyp\\Project-56',
      title: 'Bill Case 1 2025',
      category: 'Financial Assistance Drive',
      description:
          'A needy family contact us to assist them is paying the electricity bill to get back their electricity meter. Their electricity had been cut down for the last 2 years. Alhamdulillah we help them in paying the electricity bill.',
      targetGoal:
          'Assist a needy family in paying their long-standing electricity bill to restore their connection',
      itemsNeeded: 'Electricity Bill Payment',
      location: 'Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2025, 8, 5),
      eventDate: DateTime(2025, 8, 8),
      endDate: DateTime(2025, 8, 8),
      donations: 8000.0,
      expenses: 8000.0,
    );

    await _seedProject(
      projectNo: 57,
      folderPath: 'E:\\Fyp\\Project-57',
      title: 'Rashan Case 9 2025',
      category: 'Rashan Drive',
      description:
          'A needy person contact us that due to cancer he cannot work like before. We decided to help him by giving him the rashan. Alhamdullilah we delivered him the rashan. May Allah accept our little effort.',
      targetGoal: 'Provide rashan to a cancer patient who is unable to work',
      itemsNeeded:
          'Flour, Oil, Rice, Spices, Sugar, Tea, Daal, Vegetables, Cleaning Supplies',
      location: 'Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2025, 8, 20),
      eventDate: DateTime(2025, 8, 24),
      endDate: DateTime(2025, 8, 24),
      donations: 6000.0,
      expenses: 6000.0,
    );

    await _seedProject(
      projectNo: 58,
      folderPath: 'E:\\Fyp\\Project-58',
      title: 'Old Age Visit 3 2025',
      category: 'Social Welfare Drive',
      description:
          'We are going to take the team of HRAS to Affiat Old Age Home Multan. We meet with the parents of old age, arranged food for them and spend some quality time with them. May Allah bless us all.',
      targetGoal:
          'Visit Affiat Old Age Home to spend quality time with elders, provide food, and conduct activities',
      itemsNeeded:
          'Charts, Acrylic Paints, Salan Deg, Rotiyaan, Cake, Letters, Certificates, Gajray, Chairs, HRAS Stickers, Nails, Cold Drinks',
      location: 'Affiat Old Age Home, Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2025, 8, 20),
      eventDate: DateTime(2025, 10, 22),
      endDate: DateTime(2025, 10, 22),
      donations: 42150.0,
      expenses: 42150.0,
    );

    await _seedProject(
      projectNo: 59,
      folderPath: 'E:\\Fyp\\Project-59',
      title: 'Blood Test 2 2025',
      category: 'Health & Medical Drive',
      description:
          'A person in need reached out to us, expressing his inability to afford his child\'s medical tests. We assisted in arranging these tests for him. May Allah Almighty accept our humble efforts.',
      targetGoal:
          'Provide financial assistance for a child\'s medical blood tests',
      itemsNeeded: 'Blood Tests',
      location: 'Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2025, 8, 23),
      eventDate: DateTime(2025, 8, 24),
      endDate: DateTime(2025, 8, 24),
      donations: 2000.0,
      expenses: 2000.0,
    );

    await _seedProject(
      projectNo: 60,
      folderPath: 'E:\\Fyp\\Project-60',
      title: 'Flood Relief 2025',
      category: 'Flood Relief Drive',
      description:
          'We decided to arrange some Ration bags, Free medical camp, Clothes and Free water bottles for the flood victims. Alhamdullilah we provide medical facilities to more than 600 people, 200 water bottles, 40 rashan bags. May Allah accept our little effort.',
      targetGoal:
          'Provide medical facilities, ration, clothes, and clean water to flood victims',
      itemsNeeded:
          'Water bottles, Medicines, Jackets, Ration Boxes, Mosquito Nets, Pampers, Milk, Biscuits, Soaps',
      location: 'Pakistan',
      lat: 30.3753, // General Pakistan coordinate
      lng: 69.3451, // General Pakistan coordinate
      startDate: DateTime(2025, 9, 10),
      eventDate: DateTime(2025, 9, 20),
      endDate: DateTime(2025, 9, 20),
      donations: 131940.0,
      expenses: 119340.0,
    );

    await _seedProject(
      projectNo: 61,
      folderPath: 'E:\\Fyp\\Project-61',
      title: 'Rashan For Flood Victims 2025',
      category: 'Flood Relief Drive',
      description:
          'As the flood approaches in Pakistan, the HRAS team has resolved to assist our brothers and sisters affected by this disaster by providing them with essential supplies. Alhamdulillah, we have successfully served over 100 families. May Allah accept our humble efforts. Ameen.',
      targetGoal:
          'Provide rashan and essential supplies to flood-affected families in Pakistan',
      itemsNeeded: 'Rashan, Water Canes, Shields, Logistics',
      location: 'Pakistan',
      lat: 30.3753, // General Pakistan coordinate
      lng: 69.3451, // General Pakistan coordinate
      startDate: DateTime(2025, 9, 15),
      eventDate: DateTime(2025, 10, 2),
      endDate: DateTime(2025, 10, 2),
      donations: 342865.0,
      expenses: 334140.0,
    );

    await _seedProject(
      projectNo: 62,
      folderPath: 'E:\\Fyp\\Project-62',
      title: 'Dowry Items 4 2025',
      category: 'Marriage Support Drive',
      description:
          'HRAS team decided to help a needy man in arranging his daughter marriage. We provided him with support so he can arrange the marriage function completely. May Allah accept our little effort and bless all the donors.',
      targetGoal:
          'Assist a needy father in arranging his daughter\'s marriage by providing dowry items',
      itemsNeeded: 'Dinner Set, Water Set, Cup Set, Kheer Set',
      location: 'Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2025, 10, 1),
      eventDate: DateTime(2025, 10, 2),
      endDate: DateTime(2025, 10, 2),
      donations: 15500.0,
      expenses: 15500.0,
    );

    await _seedProject(
      projectNo: 63,
      folderPath: 'E:\\Fyp\\Project-63',
      title: 'Dowry Items 5 2025',
      category: 'Marriage Support Drive',
      description:
          'HRAS team decided to help a needy man in arranging his daughter marriage. We provided him with cash so he can arrange the marriage function completely. May Allah accept our little effort and bless all the donors.',
      targetGoal:
          'Assist a needy father in arranging his daughter\'s marriage by providing cash for dowry items',
      itemsNeeded: 'Cash Paid',
      location: 'Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2025, 11, 1),
      eventDate: DateTime(2025, 11, 8),
      endDate: DateTime(2025, 11, 8),
      donations: 30000.0,
      expenses: 30000.0,
    );

    await _seedProject(
      projectNo: 64,
      folderPath: 'E:\\Fyp\\Project-64',
      title: 'Medicine Case 2 2025',
      category: 'Health & Medical Drive',
      description:
          'We are going to arrange medicine and test amount for a needy female after she got a miscarriage. Alhamdullilah we help her in both things. May Allah accept our little effort. May Allah almighty bless all our donors. Ameen.',
      targetGoal:
          'Provide medical assistance (medicines and tests) for a female patient after a miscarriage',
      itemsNeeded: 'Medicine, Ultrasound',
      location: 'Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2025, 12, 1),
      eventDate: DateTime(2025, 12, 5),
      endDate: DateTime(2025, 12, 5),
      donations: 3000.0,
      expenses: 2800.0,
    );

    await _seedProject(
      projectNo: 65,
      folderPath: 'E:\\Fyp\\Project-65',
      title: 'Emotional Intelligence 2025',
      category: 'Awareness & Training Session',
      description:
          'We organized an online session on "Emotional Intelligence" via Google Meet, which was attended by over 20 members. Our speaker, Yasir Ramzan, conducted the session with great professionalism. May Allah accept our modest efforts.',
      targetGoal:
          'Conduct an online awareness session on Emotional Intelligence for the community',
      itemsNeeded: 'Online Platform, E-Certificates, Guest Speaker',
      location: 'Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2025, 12, 13),
      eventDate: DateTime(2025, 12, 13),
      endDate: DateTime(2025, 12, 13),
      donations: 0.0,
      expenses: 0.0,
    );

    await _seedProject(
      projectNo: 66,
      folderPath: 'E:\\Fyp\\Project-66',
      title: 'BBQ & Magical Night 2025',
      category: 'Social Welfare Drive',
      description:
          'We chose to welcome the New Year by celebrating with the angels of Al-Najaat Orphanage. To make the occasion special, we arranged engaging activities including a joker and magician performance, gol gappay, a BBQ, and many other funfilled moments. The joy and happiness on the children\'s faces made the celebration truly meaningful. We humbly pray that Allah accepts our small effort and blesses it with lasting impact.',
      targetGoal:
          'Celebrate New Year with orphans by arranging a BBQ, magic show, and fun activities',
      itemsNeeded:
          'BBQ Items, Magician, Gol Gappay, Cold Drinks, Fire Balloons, Catering',
      location: 'Al-Najaat Orphanage',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2025, 11, 10),
      eventDate: DateTime(2025, 12, 31),
      endDate: DateTime(2026, 1, 1),
      donations: 56190.0,
      expenses: 56190.0,
    );

    await _seedProject(
      projectNo: 67, // Using 67 for Part A (Iftar)
      folderPath: 'E:\\Fyp\\Project-67\\Iftar',
      title: 'Iftar Dastarkhwan 2026',
      category: 'Ramadan Drive',
      description:
          'In keeping with our annual tradition, we have decided to organize a weekly iftar dastarkhwan at Nishtar Hospital in Multan every Friday. Alhamdulillah, we have successfully served over 4,000 individuals. We extend our heartfelt gratitude to all members who have joined us in this noble cause. May Allah accept our humble efforts.',
      targetGoal:
          'Organize weekly iftar dastarkhwan at Nishtar Hospital for fasting patients and attendants',
      itemsNeeded:
          'Rice Degs, Dates, Jam-e-Shereen, Sugar, Samosay, Milk, Catering, Disposables, Sufrah',
      location: 'Nishtar Hospital, Multan',
      lat: 30.2017, // Nishtar Hospital approx
      lng: 71.4552,
      startDate: DateTime(2026, 1, 15),
      eventDate: DateTime(2026, 2, 20),
      endDate: DateTime(2026, 3, 20),
      donations: 347280.0,
      expenses: 347280.0,
    );

    await _seedProject(
      projectNo:
          68, // Using 68 to separate from 67 (Iftar), though user calls it 67-B. We'll stick to a distinct integer projectNo.
      folderPath:
          'E:\\Fyp\\Project-67\\Sehri', // Keeping folder path in Project-67 for clarity as per user
      title: 'Sehri Distribution 2026',
      category: 'Ramadan Drive',
      description:
          'In Ramzan 2026 we decided to add something new to our tradition. We decided to provide sehri to the people of Nishtar Hospital. Alhamdullilah we serve more than 1200 people. May Allah Almighty accept our little effort.',
      targetGoal:
          'Provide Sehri to patients and attendants at Nishtar Hospital during Ramadan',
      itemsNeeded: 'Chanay ki Deg, Naan, Shopper, Disposable Boxes',
      location: 'Nishtar Hospital, Multan',
      lat: 30.2017,
      lng: 71.4552,
      startDate: DateTime(2026, 2, 18), // Approx start of Ramadan 2026
      eventDate: DateTime(2026, 3, 1), // Sometime in Ramadan
      endDate: DateTime(2026, 3, 20), // Approx end of Ramadan 2026
      donations: 113410.0,
      expenses: 113410.0,
    );

    await _seedProject(
      projectNo: 69, // Internal DB ID 69
      folderPath: 'E:\\Fyp\\Project-68',
      title: 'Road Side Food Distribution 2026',
      category: 'Food Drive',
      description:
          'We made the decision to distribute food to the children and caregivers at the Children’s Hospital in Multan. Thanks to the grace of Allah Almighty and the support of our dedicated team members, we successfully provided rice to 300 individuals.',
      targetGoal:
          'Distribute food among patients and their attendants at the Children\'s Hospital',
      itemsNeeded: 'Rice Deg, Shopper, Disposable Box, Certificates, Stickers',
      location: 'Children\'s Hospital, Multan',
      lat: 30.1764, // Approximate coordinates for Children's Hospital Multan
      lng: 71.4398,
      startDate: DateTime(2026, 3, 20),
      eventDate: DateTime(2026, 4, 5),
      endDate: DateTime(2026, 4, 5),
      donations: 25550.0,
      expenses: 22250.0,
    );

    await _seedProject(
      projectNo: 70, // Internal DB ID 70
      folderPath: 'E:\\Fyp\\Project-69',
      title: 'Rashan Case 10 2026',
      category: 'Rashan Drive',
      description:
          'A transgender individual reached out to us for assistance in arranging food provisions for their family. By the grace of Allah Almighty, we successfully organized and delivered the rations to them. May Allah accept our efforts and bless all our donors. Ameen.',
      targetGoal:
          'Arrange rashan for a needy transgender individual and their family',
      itemsNeeded:
          'Flour, Daal Chana, Rice, Beesan, Sugar, Salt, Laal Mirch, Garam Masala, Ghee, Mong Daal, Boondhi, Sabzi',
      location: 'Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2026, 4, 1),
      eventDate: DateTime(2026, 4, 6),
      endDate: DateTime(2026, 4, 6),
      donations: 6000.0,
      expenses: 6000.0,
    );

    await _seedProject(
      projectNo: 71, // Internal DB ID 71
      folderPath: 'E:\\Fyp\\Project-70',
      title: 'Qurbani Campaign 2026',
      category: 'Qurbani Drive',
      description:
          'In continuation of our annual tradition, we organized Qurbani in 2026 for those in need, including individuals in hospitals. Alhamdulillah, we distributed over 1,000 cooked meals in hospitals and provided meat to more than 2,000 individuals.',
      targetGoal:
          'Organize Qurbani and distribute cooked meals and meat to the needy',
      itemsNeeded:
          'Slaughter Animals, Disposable Boxes, Butcher Fees, Catering, Shopper, Pakwai Fees, Wood, Sabzi',
      location: 'Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2026, 4, 27), // Approx 1 month before Bakra Eid
      eventDate: DateTime(2026, 5, 27), // Approx 1st day of Bakra Eid
      endDate: DateTime(2026, 5, 29), // Approx end of Bakra Eid 3 days
      donations: 1014774.0,
      expenses: 1001131.0,
    );

    await _seedProject(
      projectNo: 72, // Internal DB ID 72
      folderPath: 'E:\\Fyp\\Project-71',
      title: 'Free Water Distribution 1 2026',
      category: 'Water Distribution Drive',
      description:
          'Due to the extreme heat in Multan, the HRAS team decided to distribute free cold water bottles to those suffering from the sweltering conditions. Alhamdulillah, we successfully provided 1,500 water bottles to individuals in need. May Allah accept our modest efforts.',
      targetGoal: 'Distribute free cold water bottles in extreme heat',
      itemsNeeded:
          'Water Bottles, Ice, Catering + Rent, Panaflex, Certificates',
      location: 'Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2026, 5, 8),
      eventDate: DateTime(2026, 5, 15),
      endDate: DateTime(2026, 5, 15),
      donations: 32230.0,
      expenses: 32230.0,
    );

    await _seedProject(
      projectNo: 73, // Internal DB ID 73
      folderPath: 'E:\\Fyp\\Project-72',
      title: 'Bill Case 2 2026',
      category: 'Utility Bill Drive',
      description:
          'A family in need contacted us regarding their significant financial difficulties, particularly concerning an electricity bill that has been overdue for two months. Alhamdulillah, by the grace of Allah Almighty, we were able to assist by covering their electricity bill. May Allah accept our humble efforts.',
      targetGoal: 'Pay overdue electricity bill for a needy family',
      itemsNeeded: 'Electricity Bill Payment, Service Charges',
      location: 'Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2026, 6, 1),
      eventDate: DateTime(2026, 6, 15),
      endDate: DateTime(2026, 6, 15),
      donations: 4500.0,
      expenses: 4496.0,
    );

    await _seedProject(
      projectNo: 74, // Internal DB ID 74
      folderPath: 'E:\\Fyp\\Project-73',
      title: '3 Days Sabeel 2026',
      category: 'Religious & Spiritual Drive',
      description:
          'We organized a three-day Sabeel in honor of the martyrs of Karbala. This initiative serves to commemorate the sacrifices made by the Ehl-ul-Bayt. May Allah accept all our efforts. Alhamdullilah we serve more than 1000 people. May Allah bless all our donors. Ameen.',
      targetGoal:
          'Organize a 3-day Sabeel for the community in honor of the martyrs of Karbala',
      itemsNeeded:
          'Jam e shereen, Sugar, Catering, Panaflex, Disposable Glass, Certificates, Attendance Sheets, Transportation Cost, Feedback Form, Ice, Appreciation Envelope, Reel Editing Fees',
      location: 'Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2026, 6, 1),
      eventDate: DateTime(2026, 6, 16),
      endDate: DateTime(2026, 6, 18),
      donations: 17814.0,
      expenses: 17814.0,
    );

    await _seedProject(
      projectNo: 75, // Internal DB ID 75
      folderPath: 'E:\\Fyp\\Project-74',
      title: 'Medical Camp at Khanewal 2026',
      category: 'Health & Medical Drive',
      description:
          'Our team has organized a oneday free medical camp at Saleem Chowk in Khanewal. We offered complimentary check-ups, medications, blood tests, and physiotherapy to all attendees. Alhamdulillah, we successfully served over 200 individuals. May Allah Almighty accept our modest efforts.',
      targetGoal:
          'Organize a free medical camp offering check-ups, medications, and blood tests in Khanewal',
      itemsNeeded:
          'Medicines, Panaflex, Khaki Pouch, Sugar Strips, Certificates, Patient List Pages, Doctor Slips, Blood Tests, Stickers For Syrups, Plastic Small Packets, Marker Box, Ball Point Box, Shopper, Photocopy of Tests, Hand Sanitizer, Alcohol Swab, CBC Vile, Gel Vile, Plastic Bottles, Parcle Deliver',
      location: 'Saleem Chowk, Khanewal',
      lat: 30.3013, // Khanewal approx
      lng: 71.9320, // Khanewal approx
      startDate: DateTime(2026, 7, 1),
      eventDate: DateTime(2026, 7, 12),
      endDate: DateTime(2026, 7, 12),
      donations: 130600.0,
      expenses: 130600.0,
    );

    await _seedProject(
      projectNo: 76, // Internal DB ID 76
      folderPath: 'E:\\Fyp\\Project-75',
      title: 'Blood Test Case 3 2026',
      category: 'Health & Medical Drive',
      description:
          'A senior mother in need is experiencing challenges in arranging her blood test. The HRAS team has decided to assist her in facilitating the process. May Allah Almighty accept our humble efforts and bless all our donors. Ameen.',
      targetGoal:
          'Provide financial assistance for blood tests and medical checkups for a needy mother',
      itemsNeeded:
          'CBC, HBA1C, TSH, RPM, Lipid Profile, RBS, VM (HBS Ag, Anti HCV), USG Abdomen/Pelvis/KUB',
      location: 'Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2026, 6, 25),
      eventDate: DateTime(2026, 6, 29),
      endDate: DateTime(2026, 6, 29),
      donations: 13800.0,
      expenses: 13800.0,
    );

    await _seedProject(
      projectNo: 78, // Internal DB ID 78 for Project-77
      folderPath: 'E:\\Fyp\\Project-77',
      title: 'Plants Distribution Stall 2026',
      category: 'Environmental Drive',
      description:
          'On Pakistan\'s Independence Day, we devised a plan to enhance the significance of this celebration. We organized a free plant distribution stall, through which we aimed to promote a greener Pakistan. Alhamdulillah, we successfully distributed 100 plants to families, contributing to our environmental efforts.',
      targetGoal:
          'Distribute free plants on Independence Day to promote a greener environment',
      itemsNeeded:
          'Plants, Certificates, Attendance Sheets, People List, Catering, Advertisement Cards, Wooden Sticks, Awaaz-e-Niswaan Guide, Panaflex, Reel Editing Expense',
      location: 'Chungi No. 8, Multan',
      lat: 30.2100, // Approximate Multan (Chungi No 8)
      lng: 71.4600, // Approximate Multan (Chungi No 8)
      startDate: DateTime(2026, 8, 1),
      eventDate: DateTime(2026, 8, 14),
      endDate: DateTime(2026, 8, 14),
      donations: 19490.0,
      expenses: 19490.0,
    );

    await _seedProject(
      projectNo: 79, // Internal DB ID 79 for Project-78
      folderPath: 'E:\\Fyp\\Project-78',
      title: 'Free The Birds 2026',
      category: 'Animal Welfare Drive',
      description:
          'The HRAS Multan team has undertaken a commendable initiative by liberating caged birds and providing sustenance to stray animals. This project aims to encourage those around us to care for both birds and animals. Our mission is to enhance the quality of life in Pakistan for all.',
      targetGoal: 'Liberate caged birds and provide food for stray animals',
      itemsNeeded:
          'Clay Pots, Birds, Cage Rent, Daana, Rickshaw Rent, Animal Food',
      location: 'Gol Bagh Gulgasht Multan',
      lat: 30.2224, // Approximate Multan (Gol Bagh)
      lng: 71.4642, // Approximate Multan (Gol Bagh)
      startDate: DateTime(2026, 8, 20),
      eventDate: DateTime(2026, 8, 27),
      endDate: DateTime(2026, 8, 27),
      donations: 31300.0,
      expenses: 31300.0,
    );

    await _seedProject(
      projectNo: 80, // Internal DB ID 80 for Project-79
      folderPath: 'E:\\Fyp\\Project-79',
      title: 'College Fees Case 2026',
      category: 'Education Drive',
      description:
          'The HRAS Multan team has been entrusted with the responsibility of covering the tuition fees for a deserving student whose father passed away 13 years ago. Alhamdulillah, we have successfully paid her fees. May Allah Almighty accept our modest efforts and grant her success in all aspects of this life as well as in the hereafter.',
      targetGoal:
          'Provide financial assistance for college fees for an orphan student',
      itemsNeeded: 'Fees Paid',
      location: 'Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2026, 8, 20),
      eventDate: DateTime(2026, 9, 10),
      endDate: DateTime(2026, 9, 10),
      donations: 18550.0,
      expenses: 18550.0,
    );

    await _seedProject(
      projectNo: 82, // Internal DB ID 82 for Project-81 (80 is missing)
      folderPath: 'E:\\Fyp\\Project-81',
      title: 'University Fees Case 1 2026',
      category: 'Education Drive',
      description:
          'The HRAS Multan team has taken the responsibility of supporting the university education of a deserving student by covering her tuition fees. Alhamdulillah, we are grateful to have successfully paid her university fees and played a small part in helping her continue her education. May Allah Almighty accept our humble efforts, bless her with success in her studies and future, and open doors of ease, opportunities, and prosperity for her.',
      targetGoal:
          'Provide financial support for university tuition fees for a deserving student',
      itemsNeeded: 'Fees Paid',
      location: 'Multan',
      lat: 30.1575, // Default Multan
      lng: 71.5249, // Default Multan
      startDate: DateTime(2026, 9, 12),
      eventDate: DateTime(2026, 9, 15),
      endDate: DateTime(2026, 9, 15),
      donations: 28450.0,
      expenses: 28450.0,
    );
  }

  static Future<void> _seedProject({
    required int projectNo,
    required String folderPath,
    required String title,
    required String category,
    required String description,
    required String targetGoal,
    required String itemsNeeded,
    required String location,
    required double lat,
    required double lng,
    required DateTime startDate,
    DateTime? eventDate,
    required DateTime endDate,
    double donations = 0.0,
    double expenses = 0.0,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Check if project already exists
      final querySnapshot = await firestore
          .collection('campaigns')
          .where('projectSequenceNumber', isEqualTo: projectNo)
          .get();

      bool exists = querySnapshot.docs.isNotEmpty;
      String campaignId = exists
          ? querySnapshot.docs.first.id
          : const Uuid().v4();

      // If it exists, we might want to check if it already has galleryUrls to avoid re-uploading every hot restart.
      // But to ensure it gets updated with the new files, we'll overwrite it if requested.
      // For safety, let's just upload if coverImageUrl is missing or we force it.
      if (exists) {
        final data = querySnapshot.docs.first.data();
        if (data.containsKey('coverImageUrl') &&
            data['coverImageUrl'] != null) {
          debugPrint(
            'Project $projectNo already fully seeded with images. Skipping upload to save bandwidth.',
          );
          // Update basic text fields anyway
          await firestore.collection('campaigns').doc(campaignId).update({
            'title': title,
            'description': description,
            'category': category,
            'targetGoal': targetGoal,
            'location': location,
          });
          return;
        }
      }

      debugPrint('Uploading Files and Seeding Project $projectNo...');

      List<String> galleryUrls = [];
      String? documentUrl;
      String? coverUrl;
      String? videoUrl;

      // The files provided by the user
      final dir = Directory(folderPath);
      if (await dir.exists()) {
        final files = await dir.list().toList();
        for (var file in files) {
          if (file is File) {
            final fileName = file.path.split('\\').last;
            final bytes = await file.readAsBytes();
            final url = await CloudinaryService.uploadImageBytes(
              bytes,
              filename: fileName,
            );

            if (url != null) {
              if (fileName.endsWith('.pdf')) {
                documentUrl = url;
              } else if (fileName.endsWith('.mp4')) {
                videoUrl = url;
              } else if (fileName.endsWith('.xlsx') ||
                  fileName.endsWith('.xls')) {
                // For excel we can store it in documentUrl if pdf is missing, or we can just ignore or append
                // Since our model only has 1 documentUrl, if it's Project 1 which has both PDF and Excel,
                // we'll prioritize PDF for documentUrl. We can add excel to gallery for now or ignore.
              } else if (fileName == '1.jpeg') {
                coverUrl = url;
                galleryUrls.insert(0, url); // make it first
              } else if (fileName.endsWith('.jpeg') ||
                  fileName.endsWith('.jpg') ||
                  fileName.endsWith('.png')) {
                galleryUrls.add(url);
              }
            }
          }
        }
      }

      final Map<String, dynamic> projectData = {
        'id': campaignId,
        'title': title,
        'description': description,
        'category': category,
        'projectSequenceNumber': projectNo,
        'type': 'custom',
        'status': 'completed',
        'startDate': Timestamp.fromDate(startDate),
        'eventDate': eventDate != null
            ? Timestamp.fromDate(eventDate)
            : Timestamp.fromDate(endDate),
        'endDate': Timestamp.fromDate(endDate),
        'location': location,
        'latitude': lat,
        'longitude': lng,
        'coverImageUrl': coverUrl,
        'documentUrl': documentUrl,
        'videoUrl': videoUrl,
        'galleryUrls': galleryUrls,
        'targetGoal': targetGoal,
        'itemsNeeded': itemsNeeded,
        'requiredSkills': ['Management', 'Distribution', 'Field Work'],
        'totalVolunteers': 15,
        'totalDonationsAmount': donations,
        'totalDonationsCount': donations > 0 ? 5 : 0,
        'beneficiaryCount': 100, // Dummy
        'distributionCount': 100, // Dummy
        'totalExpenses': expenses,
        'progressPercent': 100,
        'createdBy': 'system',
        'createdByName': 'Admin',
        'ngoId': 'HRAS_DEFAULT_ID',
        'ngoName': 'HRAS',
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (!exists) {
        projectData['createdAt'] = FieldValue.serverTimestamp();
      }

      await firestore
          .collection('campaigns')
          .doc(campaignId)
          .set(projectData, SetOptions(merge: true));

      debugPrint('Project $projectNo Seeded Successfully!');
    } catch (e) {
      debugPrint('Error seeding Project $projectNo: $e');
    }
  }
}
