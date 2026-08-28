# 🗺️ Caça ao Tesouro AR & 3D

Um aplicativo mobile de **Realidade Aumentada e Bússola 3D** onde os jogadores seguem dicas térmicas e holográficas para encontrar um tesouro escondido usando GPS do celular.

---

## 🎮 Funcionalidades

### Sistema de Proximidade Térmica
| Estado | Passos | Distância | Cor | Shader |
|--------|--------|-----------|-----|--------|
| ❄️ **Frio** | ≥ 50 | ≥ 40m | `#87CEFA` Azul | Névoa lenta |
| 🌤️ **Morno** | < 50 | < 40m | Laranja | Pulso médio |
| 🔥 **Quente** | < 25 | < 20m | `#FF4500` Vermelho | Ondulação térmica |
| 🔥 **Muito Quente** | < 10 | < 8m | `#FF2200` Vermelho Intenso | Chamas/Brilho máximo |

### Core Features
- 🧭 **Bússola 2D Custom** com CustomPainter (leve, sem dependências pesadas)
- 🌫️ **Fragment Shader GLSL** com gradiente animado de fallback
- 📍 **GPS Real-time** com Geolocator
- 👟 **Contador de Passos** via Pedometer
- 📱 **Feedback Háptico** (vibração tátil)
- 🥽 **Realidade Aumentada** com ar_flutter_plugin (liberação aos < 10 passos)
- 🔊 **Áudio de Vitória** com audioplayers
- 🎨 **UI Glassmorphism** e animações fluidas
- 🧪 **Modo Simulação** para testes sem caminhar

---

## 🚀 Como Executar

```bash
# 1. Clone o repositório
git clone https://github.com/seu-usuario/caca-tesouro-flutter.git
cd caca-tesouro-flutter

# 2. Instale as dependências
flutter pub get

# 3. Execute no dispositivo/emulador
flutter run
```

### Permissões Necessárias (Android)
- 📍 Localização (GPS)
- 📷 Câmera (AR)
- 👟 Atividade Física (Passos)
- 📳 Vibração

---

## 🛠️ Tecnologias

| Categoria | Biblioteca |
|-----------|------------|
| GPS & Localização | `geolocator: ^10.1.0` |
| Bússola | `flutter_compass: ^0.7.0` |
| Contador de Passos | `pedometer: ^4.0.1` |
| Permissões | `permission_handler: ^11.3.1` |
| Realidade Aumentada | `ar_flutter_plugin: ^0.7.3` |
| Áudio | `audioplayers: ^6.0.0` |
| Vibração | `vibration: ^2.0.1` |
| Math/Vector | `vector_math: ^2.1.4` |

---

## 📁 Estrutura do Projeto

```
lib/
├── main.dart                          # App entry point
├── controllers/
│   ├── hunt_controller.dart           # State management central
│   └── navigation_controller.dart     # GPS, distância, bearing
├── core/
│   ├── constants/
│   │   └── app_constants.dart         # Cores, thresholds, caminhos
│   ├── services/
│   │   ├── audio_service.dart         # Reprodução de áudio
│   │   ├── haptic_service.dart        # Feedback vibratório
│   │   └── permission_service.dart    # Permissões
│   └── shaders/
│       ├── shader_controller.dart     # Fragment Shader
│       └── fog_shader_painter.dart    # Fallback gradiente
├── models/
│   └── proximity_state.dart           # Estados térmicos
└── views/
    ├── ar_treasure_screen.dart        # Tela de AR
    ├── compass_3d_view.dart           # Bússola CustomPainter
    ├── home_hunt_screen.dart          # Dashboard principal
    └── widgets/
        ├── distance_indicator.dart    # Card de métricas
        ├── proximity_badge.dart       # Badge térmico
        ├── simulation_drawer.dart     # Painel de testes
        └── tactile_radar_widget.dart  # Ondas de radar

assets/
├── shaders/fog_effect.frag             # Shader GLSL
├── models/treasure_chest.gltf         # Modelo 3D do baú
└── audio/victory.mp3                 # Som de vitória
```

---

## 🎨 Design System

### Cores
```dart
colorCold     = #87CEFA  // Azul Claro (Frio)
colorWarm     = #FF8C00  // Laranja Escuro (Morno)
colorHot      = #FF4500  // Laranja Avermelhado (Quente)
colorVeryHot  = #FF2200  // Vermelho Intenso (Muito Quente)
colorGold     = #FFD700  // Dourado (Tesouro)
colorDarkBg   = #0D1322  // Fundo escuro
colorCardBg   = #162035  // Cards glassmorphism
colorAccent   = #00E5FF  // Ciano de destaque
```

### Regras de Negócio
- **1 passo = 0.8 metros**
- Tesouros gerados em raio máximo de **60 metros**
- AR liberada apenas quando < **10 passos** do tesouro

---

## 👥 Autores

- **Samuel Mioni** & **Luiz Felipe**

---


