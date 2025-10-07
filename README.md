# RC4 Decryption Circuit

This project implements the **RC4 decryption algorithm** in hardware using **SystemVerilog** for an Intel FPGA (DE1-SoC). It follows the CPEN 311 Lab 4 structure and is divided into modular FSM-based tasks that build toward a full hardware decryption and brute-force key search system.

---

## 🧠 Overview

The circuit decrypts a 32-byte encrypted message stored in ROM and writes the decrypted plaintext to RAM. On-chip memories are generated through the Intel Quartus IP Catalog (MegaWizard). The design can be verified in simulation (ModelSim) or on hardware using the **SignalTap Logic Analyzer** and **In-System Memory Content Editor**.

---

## ⚙️ Top-Level File

- **`ksa.sv`** — The **top-level module** for the project.  
  It connects all submodules and implements the Key Scheduling Algorithm (KSA), Pseudo-Random Generation Algorithm (PRGA), and control logic.

---

## 📂 Files

- `task1.sv`, `task1_tb.sv` — Memory creation and initialization (Task 1a)  
- `task2a.sv`, `task2a_tb.sv` — Key Scheduling Algorithm (Task 2a)  
- `task2b.sv`, `task2b_tb.sv` — Pseudo-Random Generation Algorithm (Task 2b)  
- `task3.sv` — Brute-force key search combining all tasks (Task 3)  
- `s_memory_datapath_assignments.sv` — Memory interface and datapath logic  
- `message.mif` — Encrypted message used to initialize the ROM  

---

## 🧩 Tasks (Summary)

- **Task 1a – Create and initialize memory**
  - Generates the on-chip S memory (256×8) using MegaWizard/IP Catalog.  
  - Initializes each address so that `s[i] = i`.  
  - Memory contents can be viewed in the **In-System Memory Content Editor**.

- **Task 2a – Shuffle S memory (KSA)**
  - Implements the **Key Scheduling Algorithm (KSA)**.  
  - Uses a 24-bit secret key to shuffle the S memory with:  
    `j = j + s[i] + key[i mod keylength]`, swapping `s[i]` and `s[j]`.

- **Task 2b – Decrypt message (PRGA)**
  - Implements the **Pseudo-Random Generation Algorithm (PRGA)**.  
  - Reads a 32-byte encrypted message from ROM, generates the keystream, XORs it with ciphertext, and writes the decrypted message to RAM.

- **Task 3 – Brute-force key search**
  - Combines all previous tasks into a single design.  
  - Iterates through possible keys and checks for valid ASCII output (lowercase letters and spaces).  
  - Displays the current key on the HEX displays and turns on an LED when the correct key is found.
  - Or a fail message if no valid key exists 

---

## 🧰 Tools Used

- Intel Quartus Prime  
- ModelSim (simulation)  
- SignalTap Logic Analyzer  
- DE1-SoC FPGA  

---

## 🧾 How to Run

1. Place your desired `message.mif` file in the project directory before compiling.  
   (Quartus reads `.mif` files at compile time — delete the `db` folder if it’s cached.)  
2. Compile the project and program the FPGA.  
3. Use **SignalTap** or the **In-System Memory Content Editor** to view the decrypted message.  

