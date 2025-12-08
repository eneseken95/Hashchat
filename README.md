# Hashchat

<img src="https://github.com/eneseken95/Hashchat/blob/main/Hashchat/Frontend/Hashchat/App/Resources/Assets.xcassets/AppIcon.appiconset/Hashchat%202.png" alt="Logo" width="120" height="120" />

### App Name: Hashchat
##### Hashchat is a Swift/SwiftUI-powered real-time encrypted chat application that allows users to send messages secured with classical and modern cryptography — all implemented manually without external libraries.

#### 📱 Application Pages:
<img src="https://github.com/eneseken95/Hashchat/blob/main/Screenshots/Screenshot1.png" alt="Screenshoots" width="350" height="550" />
<img src="https://github.com/eneseken95/Hashchat/blob/main/Screenshots/Screenshot2.png" alt="Screenshoots" width="350" height="550" />
<img src="https://github.com/eneseken95/Hashchat/blob/main/Screenshots/Screenshot3.png" alt="Screenshoots" width="350" height="550" />
<img src="https://github.com/eneseken95/Hashchat/blob/main/Screenshots/Screenshot4.png" alt="Screenshoots" width="350" height="550" />
<img src="https://github.com/eneseken95/Hashchat/blob/main/Screenshots/Screenshot5.png" alt="Screenshoots" width="350" height="550" />

#### 🔍 Key Features:
##### -> 🔐 Multiple encryption algorithms (Caesar, Vigenère, Hill, Columnar, Rail Fence, Euclid)
##### -> 🔒 Advanced cryptography support:
##### • AES-128 (CTR Mode) — pure Swift implementation
##### • DES (CBC Mode) — full manual implementation
##### -> 🧩 Dynamic cipher selection with custom key inputs for each algorithm
##### -> 🔄 Real-time encrypted messaging using WebSockets
##### -> 🧊 Clean and modern SwiftUI interface with smooth transitions
##### -> ⚙️ Modular architecture (MVVM + DI + clean cryptography modules)
##### -> 🧠 Educational design: perfect for learning how encryption works by actually sending encrypted messages
##### -> 📡 Automatic local encryption/decryption pipeline before and after message transfer

#### 🔐 AES & DES — Manual vs CommonCrypto Implementations:
##### -> Hashchat includes both manual and library-based cryptographic systems for comparison and educational purposes.
##### Manual Implementations:
##### -> AES-128 CTR and DES CBC fully written in Swift, including round functions, S-boxes, permutations, and key scheduling.
##### CommonCrypto Implementations:
##### -> High-performance AES-128 CTR and DES CBC using Apple’s optimized cryptographic engine.
##### Built-in Benchmark System:
##### -> Measures and compares execution times of manual vs CommonCrypto implementations directly inside the app.

##### Example output:
<img src="https://github.com/eneseken95/Hashchat/blob/main/Screenshots/Screenshot6.png" alt="Screenshoots" width="350" height="550" />

#### 🛡️ Security Validation with Wireshark
##### -> To verify that messages are truly encrypted end-to-end, I used Wireshark to inspect live WebSocket packets.
##### -> All transmitted messages appear as encrypted byte streams — ensuring no plain-text data ever leaves the device.
##### -> This step helped validate the integrity of my AES and DES implementations and the overall security pipeline.

This project is licensed under the Apache License 2.0. Copyright © 2025, Enes Eken.
