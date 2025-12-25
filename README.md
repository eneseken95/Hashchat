# Hashchat

<img src="https://github.com/eneseken95/Hashchat/blob/main/Hashchat/Frontend/Hashchat/App/Resources/Assets.xcassets/AppIcon.appiconset/Hashchat%202.png" alt="Logo" width="120" height="120" />

### App Name: Hashchat
##### Hashchat is a Swift/SwiftUI-powered real-time encrypted chat application featuring classical ciphers implemented manually and modern cryptography using industry-standard frameworks.

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
##### • RSA-2048 (E2EE) — production-ready end-to-end encryption
##### -> 🧩 Dynamic cipher selection with custom key inputs for each algorithm
##### -> 🔄 Real-time encrypted messaging using WebSockets
##### -> 🧊 Clean and modern SwiftUI interface with smooth transitions
##### -> ⚙️ Modular architecture (MVVM + Clean Architecture)
##### -> 🧠 Educational design: perfect for learning how encryption works by actually sending encrypted messages
##### -> 📡 Automatic local encryption/decryption pipeline before and after message transfer

#### 🏗️ Architecture & Technology Stack
##### Frontend:
##### -> Language: Swift
##### -> UI Framework: SwiftUI
##### -> Architecture: MVVM + Clean Architecture
##### -> Reactive: Combine framework
##### -> Security: iOS Keychain (hardware-encrypted storage)
##### -> Networking: URLSession (REST), WebSocket (real-time)
##### -> Cryptography: Apple Security Framework + manual implementations

##### Backend:
##### -> Language: Python
##### -> Framework: FastAPI
##### -> Architecture: Clean Architecture (Layered Design)
##### --> Models: Pydantic validation
##### --> Routes: API endpoints (REST + WebSocket)
##### --> Services: Business logic
##### --> Database: In-memory storage (RAM)
##### -> Real-time: WebSocket message relay
##### -> API Docs: Auto-generated (Swagger UI)

<img src="https://github.com/eneseken95/Hashchat/blob/main/Screenshots/Screenshot7.png" alt="Screenshoots" width="350" height="550" />

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

#### 🔑 RSA End-to-End Encryption (E2EE)
##### -> Hashchat features production-grade End-to-End Encryption using RSA — mirroring security standards of apps like WhatsApp and Signal.

##### How it works:
##### -> Dynamic Key Generation:
- Each user gets a unique 2048-bit RSA keypair generated on first use
- Generated using Apple's `SecKeyCreateRandomKey()` with RSA-OAEP-SHA256
- No manual key generation or external tools required

##### -> Secure Storage:
- Private Key: Stored in iOS Keychain with hardware encryption (`kSecAttrAccessibleWhenUnlockedThisDeviceOnly`)
- Public Key: Distributed via backend REST API for secure message exchange
- Keys persist across app restarts and device reboots

##### -> Automatic Registration:
- On first RSA use, user is auto-registered with backend
- Public key is uploaded to server for other users to fetch
- Backend provides key distribution via REST endpoints:
  - `POST /register` — Register user with public key
  - `GET /users/{username}/public-key` — Fetch recipient's public key

##### -> Message Flow:
1. Alice types "Hello Alex"
2. App fetches Alex's public key from backend
3. Message encrypted client-side with Alex's public key (RSA-OAEP-SHA256)
4. Encrypted ciphertext sent via WebSocket
5. Alex receives encrypted message
6. Alex's app decrypts using his private key (stored in Keychain)
7. Alex sees "Hello Alex"

<img src="https://github.com/eneseken95/Hashchat/blob/main/Screenshots/Screenshot8.png" alt="Screenshoots" width="350" height="550" />

##### -> Security Features:
- Zero-knowledge server (backend cannot decrypt messages)
- Private keys never leave the device
- Hardware-backed Keychain storage
- 2048-bit RSA with modern OAEP padding
- Unique keypair per user (no shared keys)

##### -> Educational Purpose:
- Demonstrates real-world public-key cryptography
- Shows difference between symmetric (AES/DES) and asymmetric (RSA) encryption
- Teaches key management, DER formats, and E2EE pipelines
- Illustrates how modern messaging apps (WhatsApp, Signal) implement E2EE

#### 🛡️ Security Validation with Wireshark
##### -> To verify that messages are truly encrypted end-to-end, I used Wireshark to inspect live WebSocket packets.
- All transmitted messages appear as encrypted byte streams
- No plain-text data ever leaves the device
- Validates the integrity of AES, DES, and RSA implementations

This project is licensed under the Apache License 2.0. Copyright © 2025, Enes Eken.
