# Guia de Assets para Battle Screen

## Estrutura de Pastas

```
assets/
├── images/
│   ├── battle/              # Fundos e assets de batalha
│   ├── enemies/             # Sprites dos inimigos
│   ├── effects/             # Efeitos especiais (chuva binária, etc)
│   ├── player/              # Sprites do jogador
│   ├── ui/
│   │   ├── buttons/         # Botões (Luta, Mochila)
│   │   ├── hud/             # Elementos HUD (frames, barras de vida)
│   │   └── icons/           # Ícones (coração, escudo, mochila, etc)
│   ├── cards/               # Cartas (já existente)
│   ├── map/                 # Mapas (já existente)
│   └── tiles/               # Tiles (já existente)
```

## Assets Necessários

### 1. **Battle Background**
- **Arquivo**: `assets/images/battle/background.png`
- **Descrição**: Fundo da tela de batalha com cenário futurista
- **Tamanho sugerido**: 1920x1080px ou 1280x720px
- **Formato**: PNG com transparência

### 2. **Efeitos**
- **Arquivo**: `assets/images/effects/binary_rain.png`
- **Descrição**: Chuva de números binários no fundo
- **Tamanho sugerido**: 1920x1080px ou padrão (será repetido)
- **Formato**: PNG com transparência

### 3. **HUD do Inimigo**
- **enemy_frame.png**: Frame da moldura do inimigo
- **enemy_health_bar.png**: Barra de vida (opcional, pode usar LinearProgressIndicator)

### 4. **Inimigo**
- **logic_core.png**: Sprite do núcleo de lógica
- **logic_core_screen.png**: Tela vermelha do núcleo (opcional)

### 5. **HUD do Jogador**
- **player_frame.png**: Frame da moldura do jogador
- **player_sprite.png**: Sprite do soldado
- **health_bar.png**: Barra de vida (opcional)
- **shield_bar.png**: Barra de escudo (opcional)

### 6. **Botões**
- **btn_fight.png**: Botão de luta
- **btn_fight_hover.png**: Botão de luta com hover
- **btn_backpack.png**: Botão de mochila
- **btn_backpack_hover.png**: Botão de mochila com hover

### 7. **Ícones**
- **icon_heart.png**: Ícone de coração (vida)
- **icon_shield.png**: Ícone de escudo
- **icon_backpack.png**: Ícone de mochila
- **icon_level.png**: Ícone de nível

### 8. **Caixa de Diálogo**
- **dialog_box.png**: Frame da caixa de diálogo

## Como Usar

### 1. Adicionar os Assets
Coloque os arquivos PNG nas pastas correspondentes em `assets/images/`.

### 2. Referenciar nos Constantes
Todos os caminhos estão definidos em `lib/constants/asset_paths.dart`:

```dart
Image.asset(AssetPaths.battleBackground)
Image.asset(AssetPaths.logicCore)
```

### 3. Usar na Tela de Batalha
O widget `BattleScreen` em `lib/ui/battle_screen.dart` já está pronto para usar todos os assets.

```dart
import 'lib/ui/battle_screen.dart';

// Na sua navegação:
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const BattleScreen()),
);
```

## Recursos Gratuitos

Se você não tiver os assets, pode encontrar em:

- **Itch.io**: https://itch.io/game-assets/tag-pixel-art
- **OpenGameArt.org**: https://opengameart.org/
- **Pixabay**: https://pixabay.com/
- **Pexels**: https://www.pexels.com/
- **Unsplash**: https://unsplash.com/

## Dicas

1. **Tamanhos Recomendados**:
   - Fundos: 1920x1080 ou múltiplos de 16 (pixel art)
   - Sprites: 256x256, 512x512 ou tamanho apropriado para escala
   - Ícones: 64x64 ou 128x128
   - Botões: 200x60 a 300x80

2. **Transparência**: Use PNG com fundo transparente para melhor integração

3. **Otimização**: Comprima os PNGs para reduzir tamanho da app

4. **Diferentes Resoluções**: Para suportar telas variadas, use `fit: BoxFit.cover` ou `fit: BoxFit.contain`

## Próximos Passos

1. Obter ou criar os assets
2. Colocar na pasta correta
3. Testar no emulador/device
4. Ajustar tamanhos e posicionamento conforme necessário
