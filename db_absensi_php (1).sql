-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Oct 29, 2025 at 06:21 PM
-- Server version: 8.4.3
-- PHP Version: 8.3.16

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `db_absensi.php`
--

-- --------------------------------------------------------

--
-- Table structure for table `absensi`
--

CREATE TABLE `absensi` (
  `id_absensi` bigint NOT NULL,
  `id_karyawan` int NOT NULL,
  `tanggal` date NOT NULL,
  `jam_masuk` time DEFAULT NULL,
  `jam_pulang` time DEFAULT NULL,
  `status_absen` enum('hadir','terlambat','izin','sakit') DEFAULT 'hadir',
  `foto_masuk` varchar(255) DEFAULT NULL,
  `foto_pulang` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `absensi`
--

INSERT INTO `absensi` (`id_absensi`, `id_karyawan`, `tanggal`, `jam_masuk`, `jam_pulang`, `status_absen`, `foto_masuk`, `foto_pulang`) VALUES
(1, 13, '2025-10-27', '16:13:55', '16:14:04', 'terlambat', 'uploads/snaps/checkin_13_1761581635.jpg', 'uploads/snaps/checkout_13_1761581644.jpg'),
(2, 6, '2025-10-27', '16:41:58', '16:42:06', 'terlambat', 'uploads/snaps/checkin_6_1761583318.jpg', 'uploads/snaps/checkout_6_1761583326.jpg'),
(4, 15, '2025-10-28', '05:52:06', '05:52:13', 'hadir', 'uploads/snaps/checkin_15_1761630726.jpg', 'uploads/snaps/checkout_15_1761630733.jpg');

-- --------------------------------------------------------

--
-- Table structure for table `admin`
--

CREATE TABLE `admin` (
  `id_admin` int NOT NULL,
  `nama_admin` varchar(100) NOT NULL,
  `username` varchar(60) NOT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(120) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `admin`
--

INSERT INTO `admin` (`id_admin`, `nama_admin`, `username`, `password`, `email`, `created_at`) VALUES
(1, 'admin', 'admin', '$2y$10$IEHoyXxehckXhmvaB/Onje6rynRRN1gRo3kzCcyqnU4osE6fbUPJG', 'admin@example.com', '2025-10-28 03:03:08'),
(2, 'Rendy', 'admin1', '$2y$10$vxEQChR4pCv3A2c20Y5/zukwSX4wEZNKpOT2FfoF58UQ8VYRzAhJ6', 'admin@gmail.com', '2025-10-28 04:41:12');

-- --------------------------------------------------------

--
-- Table structure for table `jadwal_karyawan`
--

CREATE TABLE `jadwal_karyawan` (
  `id_jadwal` int NOT NULL,
  `id_karyawan` int NOT NULL,
  `jam_masuk` time NOT NULL,
  `jam_pulang` time NOT NULL,
  `toleransi_menit` int NOT NULL DEFAULT '15'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `jadwal_karyawan`
--

INSERT INTO `jadwal_karyawan` (`id_jadwal`, `id_karyawan`, `jam_masuk`, `jam_pulang`, `toleransi_menit`) VALUES
(1, 6, '08:00:00', '17:00:00', 15),
(3, 2, '08:00:00', '17:00:00', 15),
(5, 12, '08:00:00', '18:00:00', 20),
(6, 15, '08:00:00', '17:00:00', 15);

-- --------------------------------------------------------

--
-- Table structure for table `karyawan`
--

CREATE TABLE `karyawan` (
  `id_karyawan` int NOT NULL,
  `nama` varchar(100) NOT NULL,
  `jabatan` varchar(100) NOT NULL,
  `foto_wajah` varchar(255) DEFAULT NULL,
  `device_id` varchar(100) DEFAULT NULL,
  `status_aktif` enum('aktif','non-aktif') DEFAULT 'aktif',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `karyawan`
--

INSERT INTO `karyawan` (`id_karyawan`, `nama`, `jabatan`, `foto_wajah`, `device_id`, `status_aktif`, `created_at`) VALUES
(1, 'Rendy Krisna', 'Staff', NULL, NULL, 'aktif', '2025-10-26 21:11:11'),
(2, 'dy', 'nd', NULL, NULL, 'aktif', '2025-10-26 21:11:35'),
(3, 'dy', 'nd', NULL, NULL, 'aktif', '2025-10-26 21:11:36'),
(4, 'rendy', 'manajer', NULL, NULL, 'aktif', '2025-10-26 21:11:55'),
(5, 'Rendy Krisna', 'Staff', NULL, NULL, 'aktif', '2025-10-26 21:11:59'),
(6, 'ren', 'ren', 'uploads/faces/face_6_1761579011.jpg', NULL, 'aktif', '2025-10-27 15:26:06'),
(12, 'ra', 'manajer', NULL, NULL, 'aktif', '2025-10-27 15:42:04'),
(13, 'ama', 'ama', 'uploads/faces/face_13_1761579896.jpg', NULL, 'aktif', '2025-10-27 15:44:45'),
(15, 'amaw', 'manajer', 'uploads/faces/face_15_1761630715.jpg', NULL, 'aktif', '2025-10-28 04:36:39');

-- --------------------------------------------------------

--
-- Table structure for table `karyawan_cred`
--

CREATE TABLE `karyawan_cred` (
  `id_karyawan` int NOT NULL,
  `username` varchar(60) DEFAULT NULL,
  `password` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `karyawan_cred`
--

INSERT INTO `karyawan_cred` (`id_karyawan`, `username`, `password`) VALUES
(1, 'rendy1', '$2y$10$/S3A5TqKUXyqb95FcTEJuuXnUUYBXl3drTBC4A8BO5SPxkA6SS05G'),
(2, 'tes', '$2y$10$b4xXBOIVO6Px40dPtWcAvuveFrfPSEvqgvcLrLcL7M2hx/yNv3SO.'),
(4, 'rendy', '$2y$10$xp90g.CFt8xXXv9VtpBufe1Nu0v9mKmfdGeaNVOobY41VO2zfpV9e'),
(6, 'ren02', '$2y$10$5Sf.jtbWktpD.Yh3eSy4JumyfnmwlVazaccbmGOS16yMaObj.kg7G'),
(12, 'ran', '$2y$10$HGcALaigP4/nibLvqu5ZrOoM.0KULEfjGUt8Zd8nT9Jsq4S31gm3K'),
(13, 'ama', '$2y$10$oY6ws5473Ds13OBBO1tt9ucEyo6EDSzLNVyCAnYZmkRkxuOXGcPiG'),
(15, 'amaw', '$2y$10$HKVchLn3YNpnlAnGETUAjexDrK6ftC8IkEHXAUzEulannxwgQAQnC');

-- --------------------------------------------------------

--
-- Table structure for table `session_tokens`
--

CREATE TABLE `session_tokens` (
  `id` int NOT NULL,
  `id_karyawan` int NOT NULL,
  `token` varchar(128) NOT NULL,
  `expires_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `session_tokens`
--

INSERT INTO `session_tokens` (`id`, `id_karyawan`, `token`, `expires_at`) VALUES
(1, 6, '885a2a5d64fc9eb712c0268b8864570558165fa581692356b93b5a7c0350d8a9', '2025-10-30 15:26:06'),
(2, 12, 'b200f8b665c29fbc38ac274fa10f496e89e8243e63343b5220099aa101cad066', '2025-10-30 15:42:18'),
(3, 13, '401eee6f5fd1cf7a3ee8ea9582df571a4d9e263041c669fc862d502d836be405', '2025-10-30 15:44:45'),
(4, 13, 'dbaf24227eee900acb83f71625df600faea9b5fa3f737ae39e403dc8c7a06071', '2025-10-30 15:45:52'),
(5, 13, '93bfeca68cc76c04d9a2f3396f26691a474d65a47e7925d88bee1980260694e5', '2025-10-30 15:45:57'),
(6, 13, '024d4c6f2c0c18ba26c303fb33dcff0253beb5a7fd869dc036febcca9a3e7780', '2025-10-30 15:45:58'),
(7, 13, 'ea438258910eb99940200c60a12a0151a924456a186e16dd8fac4ed29c893334', '2025-10-30 15:45:59'),
(8, 13, '42428a8bf5c9bd7dc6f0854f150a47c94bcb74124e596c45b3f810e3804d0f51', '2025-10-30 15:46:00'),
(9, 13, '164ccb8bce93021963bd85f2e382d2ec3888f6f403efa9c5587ace5d205e66a7', '2025-10-30 15:46:00'),
(10, 13, '0eb223fb6219df0596241ad09d7c496e6e4fba402165da3e0ee34209b6b968c5', '2025-10-30 15:46:01'),
(11, 13, 'a9bf5ddc16d7aa6ffe22bdb174713d2f4ffa8f88dab0d9b698c3aabec6b596e2', '2025-10-30 15:46:01'),
(12, 13, '25424f4f03a583a6e8e35f0307398eb54097919bd4661a99f48824cb3794bf86', '2025-10-30 15:46:01'),
(13, 13, '55b7a0e20d1a571051c9dae6f8c83dddb6bd8b8c49e21961c2369307d39f0edc', '2025-10-30 15:46:02'),
(14, 13, 'b36577860b4bee0177afff094cb3c4fb01155d094c0568e88860ccfec0144c57', '2025-10-30 15:46:02'),
(15, 13, '18d2dacbcff0d243fcdbeeca3ef3abbac8ce3913c02f6468938761427b114a5e', '2025-10-30 15:46:04'),
(16, 13, 'f4d307c893d3dbe7a4e60676f481dc7affd4d38a051453c06deaadc210019565', '2025-10-30 15:46:05'),
(17, 13, '0948b0b03e5e2a2c1c6b61e5324a0d34e218e7cf3f30a1dacf1c3d2707e137cc', '2025-10-30 15:46:05'),
(18, 13, '520a162b33976ba974d370a006f88c035dd62da53680a7b36b3282dc2e454637', '2025-10-30 15:52:45'),
(19, 13, '787f499ea19049d0f78f31f07ed07c42142cd26ca0eba0bf767dae8674ea4842', '2025-10-30 16:03:28'),
(20, 13, 'dc72e0793665f92daf071e15ae5437e4108b5b633d297fbd9825f9fba4604a85', '2025-10-30 16:04:14'),
(21, 13, '7fab5cf66d58c9f8ebb5b22261277715073169495e8fbb37688f3cf94a4cd3c5', '2025-10-30 16:32:22'),
(22, 6, '6f7eb2f6a5dbf180f7bd05519f24aa4d7b2e176b25b8cb13f395093f7d2badcd', '2025-10-30 16:38:03'),
(25, 15, '42a3890fc504c558bf2cc992f947c9e07601fc8ecdb2f795340d0203eb757446', '2025-10-31 04:53:14'),
(26, 15, 'ba77ace2c4466c1d8e78e15e1b914c5992da611dd05330f4e3526ec6645d68fc', '2025-10-31 05:49:13'),
(27, 15, '1e13e8e3e1bccf2c8a7a333fc7920ff61824f81f32691780f39a2aba4c423618', '2025-10-31 05:51:41'),
(28, 15, '957c0f6de8fe0662e1dd8f8ce3b2137dfb17dcdea03019b9b8d086664652d698', '2025-10-31 06:11:36'),
(29, 15, '0814cee8d22af0658068918b891d6839169e8599d99b19c2b308be99d4647c5d', '2025-10-31 06:11:57');

-- --------------------------------------------------------

--
-- Table structure for table `tokens`
--

CREATE TABLE `tokens` (
  `id` bigint NOT NULL,
  `user_type` enum('karyawan','admin') NOT NULL,
  `user_id` int NOT NULL,
  `token` char(64) NOT NULL,
  `expired_at` datetime NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `tokens`
--

INSERT INTO `tokens` (`id`, `user_type`, `user_id`, `token`, `expired_at`, `created_at`) VALUES
(1, 'admin', 1, '4c0a9a59c61ae22421fd60482a7e7818ade03422b2ca792fddb060e0ded5f322', '2025-10-31 03:03:08', '2025-10-28 03:03:08'),
(2, 'admin', 1, 'fdf8c4fdd0e2545f0f5b4eebca7e2ccdffa80678d116c44d255fcc46f42418e7', '2025-10-31 03:20:11', '2025-10-28 03:20:11'),
(3, 'admin', 1, '664f4b4e67ab5f2dcf88f16c5510186a4a3a7e76846632ca6a7aa850de71e0d1', '2025-10-31 03:26:14', '2025-10-28 03:26:14'),
(4, 'admin', 1, '10cd0eba4137aab314402f9ed72b993f095e607009916441cb62a3fd53ea732c', '2025-10-31 03:33:26', '2025-10-28 03:33:26'),
(5, 'admin', 1, '7255d41cbc55fb273ee5dc816b65c0f71e87e8260a2f7666f3dddf364214c399', '2025-10-31 03:37:24', '2025-10-28 03:37:24'),
(6, 'admin', 1, 'e4e4f312aaac168f01bfaeb53596064773dbf29b53063cd560d683cefacce5d8', '2025-10-31 03:45:38', '2025-10-28 03:45:38'),
(7, 'admin', 1, 'ab670c3966f01cb449a706139aa070ea28343249417b4fed6da112f57588dd38', '2025-10-31 04:06:51', '2025-10-28 04:06:51'),
(8, 'admin', 1, '5737adf4cf3ec6ad609a8f237c05ee5ae00132fc3286fa910adfd9e46671beda', '2025-10-31 04:10:05', '2025-10-28 04:10:05'),
(9, 'admin', 1, '04befaa27d2f1044b4f2e5d5412dbef11ead4322d98ab41c34744dfc7405c62c', '2025-10-31 04:25:32', '2025-10-28 04:25:32'),
(10, 'admin', 1, '5a9b7baad97e491e68373edf413b9ec5342e033038831cddb201242374242a50', '2025-10-31 05:10:15', '2025-10-28 05:10:15'),
(11, 'admin', 1, '23f9a983669ff9a91b842c45273110878caf621c3a8f54254b4921bc5391fd6b', '2025-10-31 05:44:41', '2025-10-28 05:44:41'),
(12, 'admin', 1, '4898d5ef044310d3d082a67a6f0a394183c47748c5777fa400b9153e1ac1a746', '2025-10-31 05:49:24', '2025-10-28 05:49:24'),
(13, 'admin', 1, 'd1589212ef78f511e3dcb7acadccdf4cfc645aee63b86a11d206f62863abd257', '2025-10-31 05:52:30', '2025-10-28 05:52:30'),
(14, 'admin', 1, '5efd28bd9ce4ba340ad9578dc098b21ddad64b4b5586b5b425040165ecd0ccae', '2025-10-31 06:13:37', '2025-10-28 06:13:37'),
(15, 'admin', 1, '7218f17095b114fafb59bf97cea1c2a303f4d7ba245852862296dd9f492fe70c', '2025-11-01 18:17:43', '2025-10-29 18:17:43');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `absensi`
--
ALTER TABLE `absensi`
  ADD PRIMARY KEY (`id_absensi`),
  ADD UNIQUE KEY `uniq_karyawan_tanggal` (`id_karyawan`,`tanggal`);

--
-- Indexes for table `admin`
--
ALTER TABLE `admin`
  ADD PRIMARY KEY (`id_admin`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `jadwal_karyawan`
--
ALTER TABLE `jadwal_karyawan`
  ADD PRIMARY KEY (`id_jadwal`),
  ADD UNIQUE KEY `uniq_karyawan` (`id_karyawan`);

--
-- Indexes for table `karyawan`
--
ALTER TABLE `karyawan`
  ADD PRIMARY KEY (`id_karyawan`);

--
-- Indexes for table `karyawan_cred`
--
ALTER TABLE `karyawan_cred`
  ADD PRIMARY KEY (`id_karyawan`),
  ADD UNIQUE KEY `username` (`username`);

--
-- Indexes for table `session_tokens`
--
ALTER TABLE `session_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `token` (`token`),
  ADD KEY `id_karyawan` (`id_karyawan`);

--
-- Indexes for table `tokens`
--
ALTER TABLE `tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `token` (`token`),
  ADD KEY `user_type` (`user_type`,`user_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `absensi`
--
ALTER TABLE `absensi`
  MODIFY `id_absensi` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `admin`
--
ALTER TABLE `admin`
  MODIFY `id_admin` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `jadwal_karyawan`
--
ALTER TABLE `jadwal_karyawan`
  MODIFY `id_jadwal` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `karyawan`
--
ALTER TABLE `karyawan`
  MODIFY `id_karyawan` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `session_tokens`
--
ALTER TABLE `session_tokens`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=30;

--
-- AUTO_INCREMENT for table `tokens`
--
ALTER TABLE `tokens`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `absensi`
--
ALTER TABLE `absensi`
  ADD CONSTRAINT `fk_abs_karyawan` FOREIGN KEY (`id_karyawan`) REFERENCES `karyawan` (`id_karyawan`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `jadwal_karyawan`
--
ALTER TABLE `jadwal_karyawan`
  ADD CONSTRAINT `jadwal_karyawan_ibfk_1` FOREIGN KEY (`id_karyawan`) REFERENCES `karyawan` (`id_karyawan`) ON DELETE CASCADE;

--
-- Constraints for table `karyawan_cred`
--
ALTER TABLE `karyawan_cred`
  ADD CONSTRAINT `karyawan_cred_ibfk_1` FOREIGN KEY (`id_karyawan`) REFERENCES `karyawan` (`id_karyawan`) ON DELETE CASCADE;

--
-- Constraints for table `session_tokens`
--
ALTER TABLE `session_tokens`
  ADD CONSTRAINT `session_tokens_ibfk_1` FOREIGN KEY (`id_karyawan`) REFERENCES `karyawan` (`id_karyawan`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
