import 'dart:math';

import 'gender.dart';

/// Country-aware name and appearance pools used by Character Randomize.
///
/// Appearance weights are gameplay estimates, not official demographic
/// statistics. They preserve individual variation and allow exceptions.
abstract final class CulturalRandomizerCatalog {
static const Map<String, String> _nameRegionByCountry = {
'AE': 'arab',
'AR': 'latin',
'AT': 'germanic',
'AU': 'english',
'BE': 'western_european',
'BR': 'latin',
'CA': 'english',
'CH': 'germanic',
'CL': 'latin',
'CN': 'chinese',
'CO': 'latin',
'CU': 'latin',
'DE': 'germanic',
'DK': 'nordic',
'EG': 'arab',
'ES': 'iberian',
'ET': 'east_african',
'FJ': 'pacific',
'FR': 'french',
'GB': 'english',
'GH': 'west_african',
'GR': 'greek',
'ID': 'indonesian',
'IE': 'irish',
'IN': 'south_asian',
'IT': 'italian',
'JP': 'japanese',
'KE': 'east_african',
'KR': 'korean',
'MA': 'arab',
'MC': 'french',
'MX': 'latin',
'MY': 'malay',
'NG': 'west_african',
'NL': 'dutch',
'NP': 'south_asian',
'NO': 'nordic',
'NZ': 'english',
'PK': 'south_asian',
'PL': 'slavic',
'PT': 'iberian',
'RU': 'slavic',
'SA': 'arab',
'SE': 'nordic',
'SG': 'singaporean',
'TH': 'thai',
'TR': 'turkish',
'UA': 'slavic',
'US': 'english',
'VN': 'vietnamese',
'ZA': 'south_african',
'TZ': 'east_african',
'PE': 'latin',
'PH': 'filipino',
};

static const Map<String, _NamePool> _namePools = {
'arab': _NamePool(
male: ['Omar', 'Ahmed', 'Khalid', 'Youssef', 'Amir', 'Hassan', 'Abdulrahman', 'Abdullah', 'Ibrahim', 'Ismail', 'Tariq', 'Zayd', 'Hamza', 'Bilal', 'Samir', 'Karim', 'Faisal', 'Rami', 'Tamer', 'Nabil', 'Adnan', 'Faris', 'Malik', 'Mustafa', 'Saif', 'Walid', 'Mazin', 'Anwar', 'Jamal', 'Fadi'],
female: ['Aisha', 'Layla', 'Noor', 'Mariam', 'Amira', 'Salma', 'Fatima', 'Zainab', 'Yasmin', 'Huda', 'Dalia', 'Rania', 'Reem', 'Hanan', 'Iman', 'Laila', 'Dina', 'Farah', 'Rasha', 'Maha', 'Samira', 'Nadia', 'Khadija', 'Rawan', 'Ghada', 'Lubna', 'Basma', 'Amal', 'Najwa', 'Sanaa'],
family: ['Hassan', 'Khalil', 'Mansour', 'Nasser', 'Rahman', 'Saleh', 'Alami', 'Haddad', 'Hamdan', 'Darwish', 'Qureshi', 'Farouk', 'Barakat', 'Najjar', 'Jaber', 'Shami', 'Abboud', 'Masri', 'Khoury', 'Saad', 'Zaki', 'Halabi', 'Khatib', 'Azizi', 'Hariri', 'Fakhoury', 'Qasim', 'Atiyeh', 'Hamoud', 'Badr']
),
'latin': _NamePool(
male: ['Mateo', 'Diego', 'Lucas', 'Santiago', 'Gabriel', 'Rafael', 'Alejandro', 'Daniel', 'Nicolas', 'Sebastian', 'Emiliano', 'Joaquin', 'Tomas', 'Andres', 'Emilio', 'Thiago', 'Bruno', 'Damian', 'Esteban', 'Fernando', 'Ignacio', 'Javier', 'Julian', 'Leonardo', 'Manuel', 'Pablo', 'Pedro', 'Samuel', 'Vicente', 'Xavier'],
female: ['Camila', 'Valentina', 'Lucia', 'Sofia', 'Isabella', 'Elena', 'Gabriela', 'Mariana', 'Martina', 'Daniela', 'Paula', 'Abril', 'Adriana', 'Alma', 'Antonella', 'Carolina', 'Catalina', 'Fernanda', 'Florencia', 'Julieta', 'Laura', 'Micaela', 'Natalia', 'Renata', 'Rocio', 'Trinidad', 'Veronica', 'Ximena', 'Yolanda', 'Jimena'],
family: ['Garcia', 'Rodriguez', 'Martinez', 'Silva', 'Morales', 'Rojas', 'Hernandez', 'Perez', 'Gomez', 'Diaz', 'Torres', 'Ramirez', 'Flores', 'Rivera', 'Alvarez', 'Romero', 'Castillo', 'Vargas', 'Jimenez', 'Ruiz', 'Mendoza', 'Ortega', 'Navarro', 'Medina', 'Castro', 'Gutierrez', 'Chavez', 'Dominguez', 'Herrera', 'Ruiz Perez']
),
'germanic': _NamePool(
male: ['Lukas', 'Leon', 'Felix', 'Paul', 'Jonas', 'Maximilian', 'Moritz', 'Tim', 'Ben', 'Elias', 'Anton', 'Emil', 'Oskar', 'Theo', 'Jakob', 'David', 'Simon', 'Tobias', 'Florian', 'Julian', 'Sebastian', 'Matthias', 'Stefan', 'Markus', 'Niklas', 'Hannes', 'Adrian', 'Fabian', 'Vincent', 'Frederik'],
female: ['Lena', 'Mia', 'Clara', 'Anna', 'Leonie', 'Emma', 'Hannah', 'Lina', 'Johanna', 'Frieda', 'Laura', 'Sarah', 'Marie', 'Luisa', 'Pauline', 'Katharina', 'Theresa', 'Amelie', 'Greta', 'Ida', 'Lara', 'Nina', 'Pia', 'Franziska', 'Alina', 'Carina', 'Elisa', 'Marlene', 'Viktoria', 'Lara Lina'],
family: ['Muller', 'Schneider', 'Weber', 'Fischer', 'Meyer', 'Huber', 'Wagner', 'Becker', 'Schulz', 'Hoffmann', 'Schafer', 'Koch', 'Bauer', 'Richter', 'Klein', 'Wolf', 'Schröder', 'Neumann', 'Schwarz', 'Zimmermann', 'Braun', 'Kruger', 'Hartmann', 'Lange', 'Werner', 'Schmitt', 'Krause', 'Meier', 'Lehmann', 'Schmid']
),
'english': _NamePool(
male: ['Oliver', 'Jack', 'Noah', 'Henry', 'Ethan', 'James', 'William', 'Benjamin', 'Lucas', 'Alexander', 'Daniel', 'Matthew', 'Samuel', 'Joseph', 'David', 'Thomas', 'George', 'Edward', 'Oscar', 'Archie', 'Theo', 'Arthur', 'Freddie', 'Alfie', 'Charlie', 'Harry', 'Jacob', 'Logan', 'Mason', 'Isaac'],
female: ['Olivia', 'Amelia', 'Charlotte', 'Grace', 'Emily', 'Sophie', 'Isla', 'Lily', 'Ava', 'Mia', 'Ella', 'Daisy', 'Poppy', 'Ruby', 'Evie', 'Florence', 'Alice', 'Ivy', 'Freya', 'Willow', 'Elsie', 'Harper', 'Abigail', 'Lucy', 'Hannah', 'Jessica', 'Eleanor', 'Matilda', 'Rosie', 'Georgia'],
family: ['Smith', 'Taylor', 'Brown', 'Wilson', 'Martin', 'Clark', 'Johnson', 'Williams', 'Jones', 'Davies', 'Evans', 'Thomas', 'Roberts', 'Walker', 'Wright', 'Thompson', 'White', 'Hughes', 'Edwards', 'Green', 'Lewis', 'Hall', 'Wood', 'Harris', 'Baker', 'Adams', 'Nelson', 'Carter', 'Mitchell', 'Phillips']
),
'western_european': _NamePool(
male: ['Louis', 'Arthur', 'Leon', 'Gabriel', 'Adam', 'Noah', 'Antoine', 'Pierre', 'Theo', 'Maxime', 'Raphael', 'Nathan', 'Mathis', 'Enzo', 'Paul', 'Clement', 'Baptiste', 'Mael', 'Adrien', 'Valentin', 'Romain', 'Axel', 'Evan', 'Gaspard', 'Quentin', 'Florian', 'Alexandre', 'Benjamin', 'Victor', 'Romain Pierre'],
female: ['Louise', 'Alice', 'Emma', 'Juliette', 'Lea', 'Elise', 'Camille', 'Manon', 'Ines', 'Sarah', 'Pauline', 'Margot', 'Clara', 'Anais', 'Mathilde', 'Eva', 'Zoe', 'Romane', 'Louna', 'Maelys', 'Charlotte', 'Lucie', 'Emilie', 'Amandine', 'Marion', 'Noemie', 'Louna Manon', 'Marion Louise', 'Pauline Elise', 'Zoe Eva'],
family: ['Dubois', 'Lambert', 'Janssens', 'Peeters', 'Moreau', 'Simon', 'Petit', 'Robert', 'Richard', 'Durand', 'Leroy', 'Morel', 'Laurent', 'Lefebvre', 'Michel', 'Garcia', 'David', 'Bertrand', 'Roux', 'Vincent', 'Fournier', 'Girard', 'Andre', 'Mercier', 'Dupont', 'Bonnet', 'Francois', 'Legrand', 'Fournier Robert', 'Bonnet Roux']
),
'nordic': _NamePool(
male: ['Lars', 'Erik', 'Oscar', 'Magnus', 'Nils', 'Anders', 'Emil', 'William', 'Alexander', 'Elias', 'Isak', 'Viktor', 'Axel', 'Johan', 'Anton', 'Theo', 'Oliver', 'Filip', 'Gustav', 'Henrik', 'Sander', 'Tobias', 'Kristian', 'Mikkel', 'Jesper', 'Mats', 'Einar', 'Soren', 'Leif', 'Bjorn'],
female: ['Astrid', 'Freja', 'Ingrid', 'Linnea', 'Maja', 'Elsa', 'Nora', 'Saga', 'Signe', 'Thea', 'Alma', 'Ella', 'Tilde', 'Ebba', 'Tuva', 'Selma', 'Josefine', 'Hedda', 'Liv', 'Solveig', 'Frida', 'Ida', 'Agnes', 'Ronja', 'Wilma', 'Mette', 'Annika', 'Elin', 'Karin', 'Maren'],
family: ['Hansen', 'Johansson', 'Andersen', 'Lindberg', 'Berg', 'Dahl', 'Olsen', 'Larsen', 'Nilsen', 'Kristensen', 'Pedersen', 'Eriksson', 'Larsson', 'Olsson', 'Svensson', 'Karlsson', 'Lund', 'Nygaard', 'Solberg', 'Moen', 'Haugen', 'Johansen', 'Bergstrom', 'Lind', 'Holm', 'Strom', 'Vik', 'Dahlberg', 'Sandberg', 'Falk']
),
'chinese': _NamePool(
male: ['Wei', 'Jun', 'Hao', 'Ming', 'Jian', 'Lei', 'Yichen', 'Zixuan', 'Yuhang', 'Zihan', 'Yuze', 'Haoran', 'Yuxuan', 'Zimo', 'Yifan', 'Cheng', 'Bo', 'Chen', 'Peng', 'Tao', 'Qiang', 'Guo', 'Liang', 'Feng', 'Xin', 'Yong', 'Rui', 'Kai', 'Tian', 'Zhen'],
female: ['Mei', 'Xinyi', 'Jing', 'Yan', 'Lina', 'Yuting', 'Yuxi', 'Yutong', 'Zihan', 'Yihan', 'Kexin', 'Yinuo', 'Xinyu', 'Yiran', 'Qian', 'Xia', 'Hui', 'Fang', 'Lihua', 'Xiaoyu', 'Wen', 'Lian', 'Ting', 'Jia', 'Qing', 'Shuang', 'Ying', 'Rong', 'Lan', 'Xiaoyu Yutong'],
family: ['Wang', 'Li', 'Zhang', 'Liu', 'Chen', 'Yang', 'Zhao', 'Huang', 'Zhou', 'Wu', 'Xu', 'Sun', 'Ma', 'Zhu', 'Hu', 'Guo', 'He', 'Gao', 'Lin', 'Luo', 'Zheng', 'Liang', 'Xie', 'Song', 'Tang', 'Han', 'Feng', 'Yu', 'Dong', 'Xiao']
),
'japanese': _NamePool(
male: ['Haruto', 'Ren', 'Yuto', 'Sota', 'Kaito', 'Haruki', 'Sora', 'Daiki', 'Takumi', 'Ryota', 'Shota', 'Yuma', 'Itsuki', 'Riku', 'Kenta', 'Yuki', 'Tsubasa', 'Naoki', 'Hiroto', 'Koki', 'Hayato', 'Shun', 'Ryusei', 'Takeru', 'Akira', 'Kenji', 'Masato', 'Sho', 'Kazuki', 'Tomoya'],
female: ['Yui', 'Sakura', 'Hina', 'Aoi', 'Akari', 'Mei', 'Mio', 'Rin', 'Yuna', 'Nanami', 'Koharu', 'Riko', 'Misaki', 'Hinata', 'Ayaka', 'Haruka', 'Natsuki', 'Nozomi', 'Emi', 'Kaori', 'Yuka', 'Sayuri', 'Chihiro', 'Fumiko', 'Kana', 'Miku', 'Reina', 'Tomomi', 'Yoko', 'Rina'],
family: ['Sato', 'Suzuki', 'Takahashi', 'Tanaka', 'Watanabe', 'Ito', 'Yamamoto', 'Nakamura', 'Kobayashi', 'Kato', 'Yoshida', 'Yamada', 'Sasaki', 'Yamaguchi', 'Matsumoto', 'Inoue', 'Kimura', 'Hayashi', 'Shimizu', 'Mori', 'Abe', 'Ikeda', 'Hashimoto', 'Ishikawa', 'Yamazaki', 'Nakajima', 'Maeda', 'Fujita', 'Ogawa', 'Goto']
),
'korean': _NamePool(
male: ['Min-jun', 'Seo-jun', 'Do-yun', 'Ji-ho', 'Ha-jun', 'Ji-hun', 'Ji-min', 'Hyun-woo', 'Seung-min', 'Min-ho', 'Jun-ho', 'Dong-hyun', 'Tae-hyun', 'Sung-ho', 'Woo-jin', 'Ye-jun', 'Si-woo', 'Joon', 'Eun-woo', 'Gun-woo', 'Seung-hyun', 'Jae-hyun', 'Dae-hyun', 'Min-seok', 'Young-ho', 'Sang-woo', 'Hyeon', 'Jin-woo', 'Seok-jin', 'Byung-ho'],
female: ['Seo-yeon', 'Ji-woo', 'Ha-eun', 'Min-seo', 'Su-bin', 'Ye-eun', 'Ji-eun', 'Soo-jin', 'Hye-jin', 'Eun-ji', 'Da-eun', 'Ye-jin', 'Bo-ra', 'Na-eun', 'Yu-jin', 'Chae-won', 'Da-hyun', 'Ga-eun', 'Hye-won', 'So-young', 'Mi-young', 'Eun-seo', 'Ye-won', 'Ji-hye', 'Seul-gi', 'Min-ji', 'Soo-ah', 'Yu-na', 'Hyo-joo', 'Bo-young'],
family: ['Kim', 'Lee', 'Park', 'Choi', 'Jung', 'Kang', 'Yoon', 'Jang', 'Lim', 'Han', 'Oh', 'Seo', 'Shin', 'Kwon', 'Hwang', 'Ahn', 'Song', 'Jeon', 'Hong', 'Ryu', 'Moon', 'Bae', 'Baek', 'Heo', 'Nam', 'Sim', 'No', 'Ha', 'Ko', 'Cha']
),
'south_asian': _NamePool(
male: ['Arjun', 'Rohan', 'Aarav', 'Rahul', 'Aditya', 'Kiran', 'Vihaan', 'Ishaan', 'Dev', 'Kabir', 'Aryan', 'Siddharth', 'Vikram', 'Nikhil', 'Varun', 'Akash', 'Manish', 'Sanjay', 'Anil', 'Raj', 'Naveen', 'Pranav', 'Shreyas', 'Dhruv', 'Om', 'Yash', 'Aman', 'Harsh', 'Laksh', 'Sameer'],
female: ['Ananya', 'Priya', 'Aanya', 'Kavya', 'Sana', 'Diya', 'Aditi', 'Isha', 'Meera', 'Ishita', 'Riya', 'Nisha', 'Pooja', 'Neha', 'Radhika', 'Saanvi', 'Ishani', 'Tara', 'Leela', 'Shreya', 'Sneha', 'Simran', 'Tanvi', 'Vaishnavi', 'Vidya', 'Anika', 'Anjali', 'Bhavna', 'Charu', 'Divya'],
family: ['Sharma', 'Patel', 'Singh', 'Khan', 'Joshi', 'Thapa', 'Verma', 'Gupta', 'Reddy', 'Nair', 'Iyer', 'Das', 'Mehta', 'Kapoor', 'Malhotra', 'Choudhary', 'Desai', 'Rao', 'Menon', 'Banerjee', 'Mukherjee', 'Chakraborty', 'Kulkarni', 'Mishra', 'Tiwari', 'Pandey', 'Shah', 'Sinha', 'Bhat', 'Bhandari']
),
'east_african': _NamePool(
male: ['Amani', 'Baraka', 'Jabari', 'Kamau', 'Mwangi', 'Dawit', 'Abdi', 'Yusuf', 'Hassan', 'Said', 'Omari', 'Bakari', 'Rashid', 'Salim', 'Juma', 'Mussa', 'Peter', 'Joseph', 'Daniel', 'Samuel', 'Elias', 'Tesfaye', 'Alem', 'Bekele', 'Getachew', 'Girma', 'Biruk', 'Mekonnen', 'Tewodros', 'Elias Yusuf'],
female: ['Asha', 'Neema', 'Zuri', 'Wanjiku', 'Nia', 'Hana', 'Zahra', 'Halima', 'Amina', 'Fatuma', 'Saida', 'Rehema', 'Mwanaisha', 'Khadija', 'Zawadi', 'Upendo', 'Selam', 'Almaz', 'Bethlehem', 'Meseret', 'Tigist', 'Genet', 'Saba', 'Eden', 'Rahel', 'Yordanos', 'Makeda', 'Azeb', 'Hirut', 'Lemlem'],
family: ['Otieno', 'Njoroge', 'Tesfaye', 'Mushi', 'Kiptoo', 'Abebe', 'Mohamed', 'Abdi', 'Hassan', 'Ali', 'Ahmed', 'Juma', 'Mwakalinga', 'Mtei', 'Mollel', 'Mrema', 'Mgonja', 'Msuya', 'Mwita', 'Nyamweya', 'Wekesa', 'Kipchoge', 'Kiplagat', 'Cheruiyot', 'Mutiso', 'Karanja', 'Maina', 'Kebede', 'Desta', 'Worku']
),
'west_african': _NamePool(
male: ['Kwame', 'Kofi', 'Chidi', 'Emeka', 'Tunde', 'Ade', 'Oluwaseun', 'Babatunde', 'Olumide', 'Femi', 'Segun', 'Ayo', 'Chukwuemeka', 'Ifeanyi', 'Obinna', 'Uche', 'Nnamdi', 'Oladipo', 'Adewale', 'Olaitan', 'Seyi', 'Yaw', 'Kojo', 'Kwaku', 'Nana', 'Kwesi', 'Mamadou', 'Amadou', 'Sekou', 'Ibrahima'],
female: ['Ama', 'Akosua', 'Chioma', 'Adaeze', 'Abena', 'Folami', 'Folake', 'Temitope', 'Yetunde', 'Bukola', 'Bisi', 'Funke', 'Ifeoma', 'Ngozi', 'Onyeka', 'Ugochi', 'Chiamaka', 'Ada', 'Abiola', 'Kemi', 'Titilayo', 'Efua', 'Esi', 'Akua', 'Adwoa', 'Yaa', 'Aissatou', 'Aminata', 'Fatou', 'Mariama'],
family: ['Mensah', 'Okafor', 'Adeyemi', 'Boateng', 'Okonkwo', 'Bello', 'Afolabi', 'Akinyemi', 'Balogun', 'Ogunleye', 'Ojo', 'Lawal', 'Osei', 'Asante', 'Owusu', 'Appiah', 'Addo', 'Nkrumah', 'Nwosu', 'Eze', 'Obi', 'Nwachukwu', 'Diallo', 'Traore', 'Toure', 'Cisse', 'Camara', 'Konate', 'Keita', 'Bah']
),
'pacific': _NamePool(
male: ['Jone', 'Laisiasa', 'Manoa', 'Samu', 'Taito', 'Eroni', 'Peni', 'Semi', 'Viliame', 'Josaia', 'Inoke', 'Tevita', 'Iliesa', 'Epeli', 'Sione', 'Pita', 'Iosefa', 'Laki', 'Manu', 'Tane', 'Wiremu', 'Tama', 'Hemi', 'Kauri', 'Iakopo', 'Tui', 'Siale', 'Fetu', 'Malakai', 'Kitione'],
female: ['Adi', 'Mere', 'Litia', 'Salote', 'Ana', 'Luisa', 'Mereoni', 'Vika', 'Asenaca', 'Losalini', 'Kelera', 'Makereta', 'Elenoa', 'Lupe', 'Mele', 'Sina', 'Moana', 'Hinemoa', 'Aroha', 'Anahera', 'Maia', 'Hine', 'Vai', 'Lani', 'Sela', 'Atina', 'Sala', 'Merewalesi', 'Alisi', 'Anahera Vika'],
family: ['Vula', 'Naisoro', 'Rokotuibau', 'Tawake', 'Kumar', 'Singh', 'Ravoka', 'Toganivalu', 'Qarase', 'Seruvakula', 'Rabuka', 'Cakobau', 'Bale', 'Vunibobo', 'Nasilasila', 'Ratu', 'Tuiqere', 'Mataitoga', 'Koroi', 'Waqa', 'Vakatale', 'Rarawa', 'Whaitiri', 'Te Rangi', 'Ngata', 'Wihongi', 'Mahuta', 'Tupou', 'Fifita', 'Vakatale Toganivalu']
),
'french': _NamePool(
male: ['Gabriel', 'Louis', 'Jules', 'Arthur', 'Raphael', 'Hugo', 'Antoine', 'Pierre', 'Theo', 'Maxime', 'Nathan', 'Mathis', 'Enzo', 'Paul', 'Clement', 'Baptiste', 'Mael', 'Adrien', 'Valentin', 'Romain', 'Axel', 'Evan', 'Gaspard', 'Quentin', 'Florian', 'Alexandre', 'Benjamin', 'Victor', 'Romain Pierre', 'Alexandre Adrien'],
female: ['Jade', 'Louise', 'Ambre', 'Alice', 'Chloe', 'Manon', 'Camille', 'Ines', 'Sarah', 'Pauline', 'Margot', 'Clara', 'Anais', 'Lea', 'Mathilde', 'Eva', 'Zoe', 'Romane', 'Louna', 'Maelys', 'Charlotte', 'Lucie', 'Emilie', 'Amandine', 'Juliette', 'Marion', 'Noemie', 'Elise', 'Louna Manon', 'Marion Louise'],
family: ['Martin', 'Bernard', 'Dubois', 'Thomas', 'Robert', 'Richard', 'Petit', 'Durand', 'Leroy', 'Morel', 'Laurent', 'Lefebvre', 'Michel', 'Garcia', 'David', 'Bertrand', 'Roux', 'Vincent', 'Fournier', 'Moreau', 'Girard', 'Andre', 'Mercier', 'Dupont', 'Lambert', 'Bonnet', 'Francois', 'Legrand', 'Fournier Robert', 'Bonnet Roux']
),
'greek': _NamePool(
male: ['Nikos', 'Giorgos', 'Dimitris', 'Yannis', 'Andreas', 'Kostas', 'Alexandros', 'Antonis', 'Christos', 'Dimitrios', 'Evangelos', 'Ilias', 'Ioannis', 'Kyriakos', 'Leonidas', 'Manolis', 'Michalis', 'Panagiotis', 'Petros', 'Spiros', 'Stavros', 'Stefanos', 'Theodoros', 'Vasilis', 'Aris', 'Fotis', 'Lambros', 'Marios', 'Stavros Antonis', 'Fotis Petros'],
female: ['Eleni', 'Maria', 'Katerina', 'Sofia', 'Dimitra', 'Irene', 'Agapi', 'Anastasia', 'Angeliki', 'Antonia', 'Despina', 'Elpida', 'Georgia', 'Ioanna', 'Konstantina', 'Kyriaki', 'Magdalini', 'Niki', 'Paraskevi', 'Penelope', 'Rena', 'Theodora', 'Vasiliki', 'Zoe', 'Alexia', 'Chara', 'Fotini', 'Kalliopi', 'Rena Anastasia', 'Eleni Paraskevi'],
family: ['Papadopoulos', 'Papadakis', 'Nikolaidis', 'Georgiou', 'Pappas', 'Dimitriou', 'Alexiou', 'Antoniou', 'Athanasiou', 'Christodoulou', 'Economou', 'Ioannidis', 'Karagiannis', 'Katsaros', 'Konstantinou', 'Kouris', 'Lampropoulos', 'Markou', 'Papadopoulou', 'Petrou', 'Raptis', 'Sideris', 'Stavropoulos', 'Theodorou', 'Vassiliou', 'Zervas', 'Angelopoulos', 'Argyros', 'Christakis', 'Mavros']
),
'indonesian': _NamePool(
male: ['Rizky', 'Aditya', 'Dimas', 'Fajar', 'Arif', 'Bima', 'Agus', 'Andi', 'Bagus', 'Bayu', 'Candra', 'Eko', 'Galih', 'Hendra', 'Ilham', 'Joko', 'Kurnia', 'Mahendra', 'Rangga', 'Reza', 'Satria', 'Teguh', 'Wahyu', 'Yudha', 'Yoga', 'Zaki', 'Rafi', 'Akbar', 'Faris', 'Gilang'],
female: ['Putri', 'Ayu', 'Siti', 'Dewi', 'Intan', 'Nadia', 'Anisa', 'Anjani', 'Citra', 'Diah', 'Fitri', 'Kartika', 'Lestari', 'Maya', 'Melati', 'Nabila', 'Ratna', 'Rani', 'Rika', 'Sekar', 'Sri', 'Tiara', 'Wulan', 'Yuni', 'Zahra', 'Laras', 'Puspita', 'Raras', 'Safira', 'Vina'],
family: ['Wijaya', 'Saputra', 'Pratama', 'Santoso', 'Hidayat', 'Kurniawan', 'Gunawan', 'Suryadi', 'Permana', 'Kusuma', 'Nugroho', 'Purnama', 'Setiawan', 'Wibowo', 'Susanto', 'Firmansyah', 'Maulana', 'Ramadhan', 'Iskandar', 'Siregar', 'Lubis', 'Nasution', 'Simanjuntak', 'Manurung', 'Pangestu', 'Hermawan', 'Irawan', 'Darmawan', 'Haryanto', 'Sulaiman']
),
'irish': _NamePool(
male: ['Sean', 'Conor', 'Cian', 'Liam', 'Finn', 'Oisin', 'William', 'Benjamin', 'Lucas', 'Alexander', 'Daniel', 'Matthew', 'Samuel', 'Joseph', 'David', 'Thomas', 'George', 'Edward', 'Oscar', 'Archie', 'Theo', 'Arthur', 'Freddie', 'Alfie', 'Charlie', 'Harry', 'Jacob', 'Logan', 'Mason', 'Isaac'],
female: ['Aoife', 'Niamh', 'Saoirse', 'Ciara', 'Orla', 'Maeve', 'Isla', 'Lily', 'Ava', 'Mia', 'Ella', 'Daisy', 'Poppy', 'Ruby', 'Evie', 'Florence', 'Alice', 'Ivy', 'Freya', 'Willow', 'Elsie', 'Harper', 'Abigail', 'Lucy', 'Hannah', 'Jessica', 'Eleanor', 'Matilda', 'Rosie', 'Georgia'],
family: ['Murphy', 'Kelly', 'Byrne', 'Ryan', 'Walsh', 'Doyle', 'Johnson', 'Williams', 'Jones', 'Davies', 'Evans', 'Thomas', 'Roberts', 'Walker', 'Wright', 'Thompson', 'White', 'Hughes', 'Edwards', 'Green', 'Lewis', 'Hall', 'Wood', 'Harris', 'Baker', 'Adams', 'Nelson', 'Carter', 'Mitchell', 'Phillips']
),
'italian': _NamePool(
male: ['Leonardo', 'Francesco', 'Lorenzo', 'Alessandro', 'Matteo', 'Luca', 'Andrea', 'Antonio', 'Davide', 'Edoardo', 'Elia', 'Gabriele', 'Giacomo', 'Giovanni', 'Marco', 'Nicolo', 'Pietro', 'Riccardo', 'Salvatore', 'Simone', 'Tommaso', 'Angelo', 'Carlo', 'Dario', 'Enrico', 'Fabio', 'Giorgio', 'Michele', 'Stefano', 'Tommaso Antonio'],
female: ['Giulia', 'Sofia', 'Aurora', 'Giorgia', 'Chiara', 'Francesca', 'Alessia', 'Alice', 'Arianna', 'Beatrice', 'Benedetta', 'Elisa', 'Emma', 'Federica', 'Gaia', 'Ilaria', 'Irene', 'Martina', 'Nicole', 'Noemi', 'Silvia', 'Valentina', 'Viola', 'Angelica', 'Camilla', 'Carlotta', 'Eleonora', 'Laura', 'Marta', 'Silvia Alice'],
family: ['Rossi', 'Russo', 'Ferrari', 'Esposito', 'Romano', 'Ricci', 'Conti', 'Gallo', 'Costa', 'Fontana', 'Greco', 'Marino', 'Bruno', 'Galli', 'Lombardi', 'Barbieri', 'Moretti', 'Rizzo', 'Pellegrini', 'De Luca', 'Mancini', 'Giordano', 'Colombo', 'Villa', 'Ferrara', 'Serra', 'Coppola', 'Testa', 'Parisi', 'Rinaldi']
),
'malay': _NamePool(
male: ['Aiman', 'Hakim', 'Amir', 'Farhan', 'Irfan', 'Danish', 'Azlan', 'Firdaus', 'Hafiz', 'Hakimi', 'Hilmi', 'Khairul', 'Luqman', 'Muaz', 'Nazmi', 'Syafiq', 'Syahir', 'Faiz', 'Fikri', 'Imran', 'Iskandar', 'Rizal', 'Shahrul', 'Zulkifli', 'Ammar', 'Harith', 'Izzat', 'Naufal', 'Rayyan', 'Iskandar Firdaus'],
female: ['Aisyah', 'Nur', 'Siti', 'Alya', 'Amira', 'Hana', 'Balqis', 'Farah', 'Hani', 'Irdina', 'Maisarah', 'Marissa', 'Nabila', 'Nadia', 'Qistina', 'Raihana', 'Sofea', 'Syazana', 'Tasnim', 'Umairah', 'Wani', 'Yasmin', 'Zara', 'Zulaikha', 'Aleesya', 'Damia', 'Husna', 'Iman', 'Jannah', 'Kirana'],
family: ['Abdullah', 'Ismail', 'Rahman', 'Hassan', 'Ibrahim', 'Yusof', 'Ahmad', 'Ali', 'Osman', 'Hamzah', 'Othman', 'Salleh', 'Yaakob', 'Zakaria', 'Zainal', 'Latif', 'Mahmud', 'Mat', 'Mohamad', 'Mustaffa', 'Omar', 'Said', 'Samad', 'Shukor', 'Taib', 'Yusoff', 'Zainuddin', 'Azman', 'Bahari', 'Ghazali']
),
'dutch': _NamePool(
male: ['Daan', 'Sem', 'Milan', 'Lucas', 'Finn', 'Lars', 'Bram', 'Gijs', 'Jesse', 'Julian', 'Luuk', 'Mees', 'Thijs', 'Timo', 'Tim', 'Sven', 'Jelle', 'Joost', 'Pieter', 'Bas', 'Diederik', 'Floris', 'Hendrik', 'Jeroen', 'Koen', 'Martijn', 'Sjoerd', 'Wouter', 'Bas Gijs', 'Martijn Joost'],
female: ['Emma', 'Sophie', 'Julia', 'Tess', 'Mila', 'Sanne', 'Anne', 'Evi', 'Femke', 'Fenne', 'Floor', 'Isa', 'Lieke', 'Lotte', 'Maud', 'Noor', 'Roos', 'Sara', 'Suus', 'Yara', 'Anouk', 'Bente', 'Esmee', 'Ilse', 'Jolien', 'Kim', 'Marit', 'Merel', 'Sterre', 'Yara Evi'],
family: ['de Jong', 'Jansen', 'de Vries', 'van den Berg', 'Bakker', 'Visser', 'Smit', 'Meijer', 'de Boer', 'Mulder', 'de Groot', 'Bos', 'Vos', 'Peters', 'Hendriks', 'Dekker', 'van Dijk', 'Brouwer', 'de Wit', 'Dijkstra', 'Smits', 'de Graaf', 'van Leeuwen', 'Koster', 'Vermeulen', 'van der Meer', 'van der Linden', 'Prins', 'van Vliet', 'Dijkstra Smit']
),
'slavic': _NamePool(
male: ['Aleksandr', 'Maksim', 'Danylo', 'Ivan', 'Nikolai', 'Marek', 'Andrei', 'Bogdan', 'Boris', 'Damian', 'Denis', 'Dmitri', 'Igor', 'Jakub', 'Jan', 'Kirill', 'Luka', 'Mateusz', 'Michal', 'Oleg', 'Pavel', 'Piotr', 'Stanislav', 'Tomasz', 'Viktor', 'Vitali', 'Wojciech', 'Yuri', 'Zbigniew', 'Oleg Bogdan'],
female: ['Anastasia', 'Olena', 'Sofia', 'Katarzyna', 'Anna', 'Mila', 'Alina', 'Daria', 'Dominika', 'Elena', 'Eva', 'Iryna', 'Ivana', 'Jana', 'Karolina', 'Kira', 'Klara', 'Lidia', 'Ludmila', 'Natalia', 'Nina', 'Polina', 'Renata', 'Svetlana', 'Tatiana', 'Valentina', 'Vera', 'Viktoria', 'Zofia', 'Zuzanna'],
family: ['Ivanov', 'Kowalski', 'Shevchenko', 'Petrov', 'Novak', 'Kravchenko', 'Sokolov', 'Smirnov', 'Kuznetsov', 'Popov', 'Sidorov', 'Volkov', 'Morozov', 'Lebedev', 'Kozlov', 'Semyonov', 'Zielinski', 'Szymanski', 'Dabrowski', 'Lewandowski', 'Wozniak', 'Malinowski', 'Kaczmarek', 'Mazur', 'Horvat', 'Kovač', 'Jovanovic', 'Markovic', 'Popescu', 'Ionescu']
),
'iberian': _NamePool(
male: ['Hugo', 'Mateo', 'Martin', 'Tiago', 'Diego', 'Alejandro', 'Adrian', 'Alvaro', 'Antonio', 'Carlos', 'Daniel', 'David', 'Enrique', 'Fernando', 'Francisco', 'Gonzalo', 'Iker', 'Javier', 'Jorge', 'Jose', 'Juan', 'Luis', 'Miguel', 'Pablo', 'Rodrigo', 'Sergio', 'Vicente', 'Xabier', 'Xoel', 'Ruben'],
female: ['Ines', 'Carmen', 'Lucia', 'Mariana', 'Beatriz', 'Alba', 'Aitana', 'Alejandra', 'Alicia', 'Ana', 'Blanca', 'Claudia', 'Daniela', 'Elena', 'Eva', 'Isabel', 'Jimena', 'Lola', 'Marta', 'Noa', 'Nuria', 'Olivia', 'Pilar', 'Raquel', 'Sara', 'Teresa', 'Valeria', 'Vega', 'Vera', 'Noa Alejandra'],
family: ['Garcia', 'Silva', 'Fernandez', 'Santos', 'Costa', 'Lopez', 'Alonso', 'Alvarez', 'Blanco', 'Cabrera', 'Campos', 'Dominguez', 'Gil', 'Iglesias', 'Marin', 'Mendez', 'Molina', 'Munoz', 'Ortiz', 'Pascual', 'Prieto', 'Ramirez', 'Serrano', 'Suarez', 'Vega', 'Vidal', 'Pereira', 'Carvalho', 'Pascual Alvarez', 'Iglesias Munoz']
),
'singaporean': _NamePool(
male: ['Wei Ming', 'Jun Jie', 'Hafiz', 'Arjun', 'Daniel', 'Ryan', 'Jun Hao', 'Zhi Wei', 'Kai Wen', 'Ming Jie', 'Jia Hao', 'Wei Jie', 'Muhammad', 'Firdaus', 'Syed', 'Danish', 'Rohan', 'Vikram', 'Karthik', 'Anand', 'Ashwin', 'Benjamin', 'Ethan', 'Joshua', 'Matthew', 'Marcus', 'Shawn', 'Zachary', 'Anand Zhi Wei', 'Ryan Vikram'],
female: ['Jia Yi', 'Xin Yi', 'Nurul', 'Priya', 'Chloe', 'Alicia', 'Xin Hui', 'Jia Min', 'Yi Xuan', 'Hui Min', 'Pei Shan', 'Wen Qi', 'Nur Aisyah', 'Siti Hajar', 'Farzana', 'Izzah', 'Anjali', 'Kavitha', 'Lakshmi', 'Nandini', 'Divya', 'Aisha', 'Grace', 'Hannah', 'Isabelle', 'Megan', 'Rachel', 'Sarah', 'Vanessa', 'Divya Jia Min'],
family: ['Tan', 'Lim', 'Lee', 'Ng', 'Wong', 'Kaur', 'Chua', 'Goh', 'Koh', 'Toh', 'Yeo', 'Seah', 'Teo', 'Chew', 'Ho', 'Tng', 'Abdul', 'Mohamed', 'Abdullah', 'Subramaniam', 'Pillai', 'Nair', 'Menon', 'Krishnan', 'Chan', 'Chong', 'Sim', 'Seow', 'Pang', 'Pillai Goh']
),
'thai': _NamePool(
male: ['Narin', 'Krit', 'Anan', 'Thanawat', 'Phurin', 'Somchai', 'Anurak', 'Apichat', 'Chai', 'Chanin', 'Chatchai', 'Kittipong', 'Nattapong', 'Pakorn', 'Preecha', 'Sakda', 'Sombat', 'Surasak', 'Teerawat', 'Thana', 'Thanakorn', 'Viroj', 'Weerachai', 'Worawut', 'Chanon', 'Kritsada', 'Narong', 'Phichit', 'Prasert', 'Thanakorn Apichat'],
female: ['Araya', 'Kanya', 'Mali', 'Nicha', 'Siriporn', 'Pim', 'Achara', 'Busaba', 'Chalida', 'Duangkamol', 'Kanda', 'Kanchana', 'Lalita', 'Malee', 'Napaporn', 'Orathai', 'Patcharee', 'Rattana', 'Suda', 'Supaporn', 'Thidarat', 'Ubon', 'Waranya', 'Wipa', 'Yada', 'Yupa', 'Chompoo', 'Pimchanok', 'Sirilak', 'Thidarat Busaba'],
family: ['Saetang', 'Srisai', 'Sukhum', 'Chaiyaporn', 'Wong', 'Kittisak', 'Chaimongkol', 'Chantarangsu', 'Charoen', 'Charoensuk', 'Chitpanya', 'Inthachai', 'Khamkaew', 'Kittikul', 'Klinchan', 'Limsakul', 'Meesuk', 'Phromsiri', 'Rattanakosin', 'Saelim', 'Sanguan', 'Srisuk', 'Thongchai', 'Thongdee', 'Udom', 'Vong', 'Wongprasert', 'Yodthong', 'Yuktanand', 'Boonma']
),
'turkish': _NamePool(
male: ['Emir', 'Yusuf', 'Kerem', 'Mehmet', 'Arda', 'Can', 'Ahmet', 'Ali', 'Arif', 'Baran', 'Berk', 'Burak', 'Cem', 'Deniz', 'Efe', 'Emre', 'Furkan', 'Hakan', 'Kaan', 'Mert', 'Onur', 'Ozan', 'Serkan', 'Sinan', 'Tolga', 'Umut', 'Volkan', 'Yasin', 'Yigit', 'Ömer'],
female: ['Zeynep', 'Elif', 'Defne', 'Ece', 'Merve', 'Aylin', 'Açelya', 'Asli', 'Ayşe', 'Bahar', 'Beren', 'Ceren', 'Damla', 'Derya', 'Esra', 'Gül', 'Gizem', 'Hazal', 'İrem', 'Melis', 'Özge', 'Pelin', 'Seda', 'Selin', 'Sevim', 'Şebnem', 'Tuğba', 'Yasemin', 'Yildiz', 'Zehra'],
family: ['Yilmaz', 'Kaya', 'Demir', 'Sahin', 'Celik', 'Aydin', 'Acar', 'Arslan', 'Aslan', 'Aydemir', 'Bayram', 'Bulut', 'Çetin', 'Doğan', 'Erdem', 'Güler', 'Güneş', 'Kaplan', 'Karaca', 'Koç', 'Kurt', 'Özdemir', 'Polat', 'Şimşek', 'Şahin', 'Taş', 'Tekin', 'Yıldırım', 'Yılmazer', 'Yüce']
),
'vietnamese': _NamePool(
male: ['Minh', 'Quang', 'Huy', 'Duc', 'Tuan', 'Khoa', 'An', 'Bao', 'Binh', 'Cuong', 'Duy', 'Giang', 'Hai', 'Hoang', 'Kien', 'Lam', 'Long', 'Nam', 'Phong', 'Phuc', 'Son', 'Thanh', 'Thien', 'Thinh', 'Trung', 'Vinh', 'Dat', 'Khang', 'Nghia', 'Tien'],
female: ['Linh', 'Anh', 'Thao', 'Trang', 'Ngoc', 'Mai', 'Bich', 'Chau', 'Diep', 'Dung', 'Ha', 'Hanh', 'Hoa', 'Huong', 'Khanh', 'Kim', 'Lan', 'My', 'Nhi', 'Phuong', 'Quynh', 'Thuy', 'Tram', 'Uyen', 'Van', 'Yen', 'Bao Ngoc', 'Gia Han', 'Minh Anh', 'Thanh Truc'],
family: ['Nguyen', 'Tran', 'Le', 'Pham', 'Hoang', 'Phan', 'Bui', 'Dang', 'Do', 'Duong', 'Ho', 'Huynh', 'Lam', 'Ly', 'Ngo', 'Phung', 'Quach', 'Ta', 'Thai', 'Trinh', 'Truong', 'Vu', 'Vo', 'Dinh', 'Cao', 'Mai', 'Luu', 'Ton', 'Thai Dang', 'Mai Quach']
),
'filipino': _NamePool(
male: ['Miguel', 'Gabriel', 'Jose', 'Andres', 'Rafael', 'Juan', 'Antonio', 'Carlo', 'Christian', 'Daniel', 'Enrico', 'Francis', 'Joaquin', 'Lorenzo', 'Marco', 'Paolo', 'Patrick', 'Ramon', 'Ricardo', 'Roberto', 'Tomas', 'Vicente', 'Adrian', 'Alfonso', 'Angelo', 'Arturo', 'Benigno', 'Cesar', 'Eduardo', 'Felipe'],
female: ['Maria', 'Angel', 'Sofia', 'Isabella', 'Andrea', 'Gabriela', 'Angela', 'Beatriz', 'Bianca', 'Carla', 'Cristina', 'Daniela', 'Diana', 'Erika', 'Isabel', 'Josefina', 'Katrina', 'Lourdes', 'Maricel', 'Marisol', 'Patricia', 'Pilar', 'Regina', 'Teresa', 'Victoria', 'Alyssa', 'Bernadette', 'Clarissa', 'Emilia', 'Josephine'],
family: ['Santos', 'Reyes', 'Cruz', 'Bautista', 'Garcia', 'Mendoza', 'Aquino', 'Castillo', 'Dela Cruz', 'Fernandez', 'Flores', 'Gonzales', 'Herrera', 'Lopez', 'Mercado', 'Navarro', 'Ocampo', 'Padilla', 'Pascual', 'Ramos', 'Rivera', 'Salazar', 'Santiago', 'Soriano', 'Torres', 'Valdez', 'Villanueva', 'Aguilar', 'Alvarado', 'Rivera Castillo']
),
'south_african': _NamePool(
male: ['Thabo', 'Sipho', 'Liam', 'Lethabo', 'Nkosi', 'Musa', 'Bongani', 'Bheki', 'Dumisani', 'Jabulani', 'Kabelo', 'Kagiso', 'Karabo', 'Mandla', 'Mpho', 'Sibusiso', 'Siphesihle', 'Themba', 'Thulani', 'Vusi', 'Xolani', 'Andile', 'Ayanda', 'Lunga', 'Nkosinathi', 'Sizwe', 'Tshepo', 'Vuyo', 'Zanele', 'Siyabonga'],
female: ['Naledi', 'Amahle', 'Thandiwe', 'Lerato', 'Zanele', 'Amara', 'Ayanda', 'Bontle', 'Busisiwe', 'Dineo', 'Lindiwe', 'Nandi', 'Nompumelelo', 'Nosipho', 'Palesa', 'Refilwe', 'Sindi', 'Thobeka', 'Thuli', 'Zinhle', 'Zodwa', 'Boitumelo', 'Keneilwe', 'Lesedi', 'Mapula', 'Thandeka', 'Zinhle Bontle', 'Naledi Thobeka', 'Lerato Thandeka', 'Sindi Refilwe'],
family: ['Nkosi', 'Dlamini', 'Mokoena', 'Naidoo', 'Botha', 'Mthembu', 'Mahlangu', 'Maseko', 'Mkhize', 'Mthethwa', 'Ndlovu', 'Ngcobo', 'Nkambule', 'Nxumalo', 'Shabalala', 'Sithole', 'Zulu', 'Khumalo', 'Msimang', 'Dube', 'Molefe', 'Motsepe', 'Modise', 'Mashaba', 'Mabuza', 'Mhlongo', 'Mofokeng', 'Molefe Maseko', 'Mofokeng Msimang', 'Ndlovu Maseko']
)
};

static const Map<String, String> _appearanceRegionByCountry = {
'AE': 'west_asian',
'AR': 'latin_america',
'AT': 'europe',
'AU': 'mixed',
'BE': 'europe',
'BR': 'latin_america',
'CA': 'mixed',
'CH': 'europe',
'CL': 'latin_america',
'CN': 'east_asian',
'CO': 'latin_america',
'CU': 'latin_america',
'DE': 'europe',
'DK': 'northern_europe',
'EG': 'north_african',
'ES': 'southern_europe',
'ET': 'east_african',
'FJ': 'pacific',
'FR': 'western_europe',
'GB': 'mixed',
'GH': 'west_african',
'GR': 'southern_europe',
'ID': 'southeast_asian',
'IE': 'northern_europe',
'IN': 'south_asian',
'IT': 'southern_europe',
'JP': 'east_asian',
'KE': 'east_african',
'KR': 'east_asian',
'MA': 'north_african',
'MC': 'western_europe',
'MX': 'latin_america',
'MY': 'southeast_asian',
'NG': 'west_african',
'NL': 'western_europe',
'NP': 'south_asian',
'NO': 'northern_europe',
'NZ': 'mixed',
'PK': 'south_asian',
'PL': 'eastern_europe',
'PT': 'southern_europe',
'RU': 'eastern_europe',
'SA': 'west_asian',
'SE': 'northern_europe',
'SG': 'southeast_asian',
'TH': 'southeast_asian',
'TR': 'west_asian',
'UA': 'eastern_europe',
'US': 'mixed',
'VN': 'southeast_asian',
'ZA': 'southern_africa',
'TZ': 'east_african',
'PE': 'latin_america',
'PH': 'southeast_asian',
};

static const Map<String, _AppearancePool> _appearancePools = {
'east_asian': _AppearancePool(
skin: ['light', 'light', 'light_medium', 'light_medium', 'medium', 'very_light', 'medium_tan'],
hair: ['black', 'black', 'blue_black', 'dark_brown', 'dark_brown', 'chocolate_brown', 'chestnut_brown'],
eyes: ['dark_brown', 'dark_brown', 'brown', 'black', 'black', 'chocolate', 'hazel'],
),
'southeast_asian': _AppearancePool(
skin: ['light_medium', 'medium', 'medium', 'medium_tan', 'tan', 'light', 'deep_tan', 'brown'],
hair: ['black', 'black', 'blue_black', 'dark_brown', 'dark_brown', 'chocolate_brown', 'chestnut_brown'],
eyes: ['dark_brown', 'dark_brown', 'brown', 'black', 'black', 'chocolate', 'amber'],
),
'south_asian': _AppearancePool(
skin: ['light_medium', 'medium', 'medium_tan', 'medium_tan', 'tan', 'deep_tan', 'brown', 'light'],
hair: ['black', 'black', 'dark_brown', 'dark_brown', 'chocolate_brown', 'blue_black', 'chestnut_brown'],
eyes: ['dark_brown', 'dark_brown', 'brown', 'brown', 'black', 'chocolate', 'hazel', 'amber'],
),
'west_asian': _AppearancePool(
skin: ['light', 'light_medium', 'medium', 'medium', 'medium_tan', 'tan', 'very_light', 'deep_tan'],
hair: ['black', 'dark_brown', 'dark_brown', 'chocolate_brown', 'chestnut_brown', 'auburn', 'blue_black'],
eyes: ['brown', 'dark_brown', 'dark_brown', 'hazel', 'amber', 'green', 'black'],
),
'north_african': _AppearancePool(
skin: ['light_medium', 'medium', 'medium_tan', 'tan', 'deep_tan', 'light', 'brown'],
hair: ['black', 'dark_brown', 'dark_brown', 'chocolate_brown', 'chestnut_brown', 'auburn'],
eyes: ['brown', 'dark_brown', 'dark_brown', 'hazel', 'amber', 'black', 'green'],
),
'east_african': _AppearancePool(
skin: ['brown', 'deep_brown', 'deep_brown', 'dark', 'dark', 'very_dark', 'deep_tan', 'tan'],
hair: ['black', 'black', 'blue_black', 'dark_brown', 'chocolate_brown'],
eyes: ['dark_brown', 'dark_brown', 'brown', 'black', 'chocolate'],
),
'west_african': _AppearancePool(
skin: ['deep_brown', 'deep_brown', 'dark', 'dark', 'very_dark', 'very_dark', 'brown', 'tan'],
hair: ['black', 'black', 'blue_black', 'dark_brown', 'chocolate_brown'],
eyes: ['dark_brown', 'dark_brown', 'black', 'black', 'brown', 'chocolate'],
),
'southern_africa': _AppearancePool(
skin: ['deep_brown', 'dark', 'brown', 'medium_tan', 'tan', 'light_medium', 'light', 'very_dark'],
hair: ['black', 'black', 'dark_brown', 'chocolate_brown', 'chestnut_brown', 'ash_brown'],
eyes: ['dark_brown', 'brown', 'black', 'hazel', 'amber', 'green'],
),
'latin_america': _AppearancePool(
skin: ['light', 'light_medium', 'medium', 'medium', 'medium_tan', 'tan', 'brown', 'deep_tan', 'pale'],
hair: ['black', 'dark_brown', 'dark_brown', 'chocolate_brown', 'chestnut_brown', 'warm_brown', 'auburn'],
eyes: ['brown', 'dark_brown', 'dark_brown', 'hazel', 'amber', 'black', 'green', 'blue_green'],
),
'southern_europe': _AppearancePool(
skin: ['pale', 'very_light', 'light', 'light_medium', 'medium', 'medium', 'tan'],
hair: ['dark_brown', 'dark_brown', 'chocolate_brown', 'chestnut_brown', 'black', 'auburn', 'warm_brown'],
eyes: ['brown', 'dark_brown', 'hazel', 'green', 'blue_green', 'gray', 'light_blue'],
),
'western_europe': _AppearancePool(
skin: ['pale', 'pale', 'very_light', 'very_light', 'light', 'light_medium', 'medium'],
hair: ['dark_brown', 'chestnut_brown', 'ash_brown', 'honey_blonde', 'golden_blonde', 'ginger', 'black'],
eyes: ['deep_blue', 'light_blue', 'gray', 'green', 'hazel', 'brown', 'blue_green'],
),
'northern_europe': _AppearancePool(
skin: ['pale', 'pale', 'very_light', 'very_light', 'light', 'light_medium'],
hair: ['honey_blonde', 'golden_blonde', 'ash_blonde', 'platinum_blonde', 'chestnut_brown', 'ash_brown', 'dark_brown'],
eyes: ['light_blue', 'deep_blue', 'gray', 'green', 'blue_green', 'hazel', 'brown'],
),
'eastern_europe': _AppearancePool(
skin: ['pale', 'very_light', 'very_light', 'light', 'light_medium', 'medium'],
hair: ['dark_brown', 'ash_brown', 'chestnut_brown', 'honey_blonde', 'ash_blonde', 'black', 'golden_blonde'],
eyes: ['gray', 'light_blue', 'deep_blue', 'green', 'hazel', 'brown', 'dark_brown'],
),
'europe': _AppearancePool(
skin: ['pale', 'very_light', 'light', 'light_medium', 'medium'],
hair: ['dark_brown', 'chestnut_brown', 'ash_brown', 'honey_blonde', 'black', 'auburn'],
eyes: ['brown', 'hazel', 'green', 'gray', 'light_blue', 'deep_blue'],
),
'pacific': _AppearancePool(
skin: ['medium', 'medium_tan', 'tan', 'deep_tan', 'brown', 'light_medium'],
hair: ['black', 'blue_black', 'dark_brown', 'chocolate_brown'],
eyes: ['dark_brown', 'brown', 'black', 'hazel'],
),
'mixed': _AppearancePool(
skin: ['pale', 'very_light', 'light', 'light_medium', 'medium', 'medium_tan', 'tan', 'deep_tan', 'brown', 'deep_brown', 'dark'],
hair: ['black', 'dark_brown', 'chocolate_brown', 'chestnut_brown', 'ash_brown', 'honey_blonde', 'auburn', 'ginger'],
eyes: ['dark_brown', 'brown', 'hazel', 'green', 'gray', 'light_blue', 'deep_blue', 'blue_green'],
),
};

/// Returns a culturally informed given-name candidate.
static String randomFirstName({
required String countryCode,
required Gender gender,
required Random random,
}) {
final pool = _namePoolFor(countryCode);
final names = gender == Gender.female ? pool.female : pool.male;
return names[random.nextInt(names.length)];
}

/// Returns a culturally informed family-name candidate.
static String randomLastName({
required String countryCode,
required Random random,
}) {
final names = _namePoolFor(countryCode).family;
return names[random.nextInt(names.length)];
}

/// Picks a palette ID using the selected country's weighted profile.
///
/// [availableIds] must come from the existing palette service. If a
/// profile ever references an unavailable ID, it is filtered out.
/// If filtering leaves no candidates, all available palette IDs are used.
static String randomAppearanceColor({
required String countryCode,
required AppearanceFeature feature,
required Iterable<String> availableIds,
required Random random,
}) {
final available = availableIds.toSet().toList(growable: false);
if (available.isEmpty) {
throw ArgumentError.value(
availableIds,
'availableIds',
'Palette must contain at least one color ID.',
);
}

final region = _appearanceRegionByCountry[
      countryCode.trim().toUpperCase()
    ] ??
    'mixed';

final profile = _appearancePools[region] ?? _appearancePools['mixed']!;
final List<String> weightedIds;

switch (feature) {
  case AppearanceFeature.skin:
    weightedIds = profile.skin;
  case AppearanceFeature.hair:
    weightedIds = profile.hair;
  case AppearanceFeature.eyes:
    weightedIds = profile.eyes;
}

final candidates = weightedIds
    .where(available.contains)
    .toList(growable: false);

final pool = candidates.isEmpty ? available : candidates;
return pool[random.nextInt(pool.length)];

}

/// Returns name-candidate counts for the country’s mapped cultural pool.
///
/// The unique counts make catalog coverage testable without exposing mutable
/// internal name lists or changing the random-name generation API.
static Map<String, int> namePoolStatsForCountry(String countryCode) {
  final pool = _namePoolFor(countryCode);
  return <String, int>{
    'male': pool.male.length,
    'maleUnique': pool.male.toSet().length,
    'female': pool.female.length,
    'femaleUnique': pool.female.toSet().length,
    'family': pool.family.length,
    'familyUnique': pool.family.toSet().length,
  };
}

/// Exposed for tests to ensure the catalog covers every supported country.
static bool supportsCountry(String countryCode) {
final code = countryCode.trim().toUpperCase();
return _nameRegionByCountry.containsKey(code) &&
_appearanceRegionByCountry.containsKey(code);
}

static _NamePool _namePoolFor(String countryCode) {
final code = countryCode.trim().toUpperCase();
final region = _nameRegionByCountry[code] ?? 'english';
return _namePools[region] ?? _namePools['english']!;
}
}

enum AppearanceFeature {
skin,
hair,
eyes,
}

class _NamePool {
const _NamePool({
required this.male,
required this.female,
required this.family,
});

final List<String> male;
final List<String> female;
final List<String> family;
}

class _AppearancePool {
const _AppearancePool({
required this.skin,
required this.hair,
required this.eyes,
});

final List<String> skin;
final List<String> hair;
final List<String> eyes;
}
