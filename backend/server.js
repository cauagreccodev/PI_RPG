require('dotenv').config();

const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const app = express();
const PORT = process.env.PORT || 3000;
const MONGO_URI = process.env.MONGO_URI;
const JWT_SECRET = process.env.JWT_SECRET;

app.use(cors());
app.use(express.json());

const userSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      trim: true,
    },
    email: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      lowercase: true,
    },
    password: {
      type: String,
      required: true,
    },
    gameState: {
      hp: { type: Number, default: 100 },
      maxHp: { type: Number, default: 100 },
      currentPhase: { type: String, default: 'Início' },
      inventory: { type: Array, default: [] },
      defeatedPhases: { type: Array, default: [] },
    },
  },
  {
    timestamps: true,
  }
);

userSchema.index({ email: 1 }, { unique: true });

const User = mongoose.model('User', userSchema);

function generateToken(userId) {
  return jwt.sign({ userId }, JWT_SECRET, {
    expiresIn: '7d',
  });
}

function serializeUser(user) {
  return {
    _id: user._id,
    name: user.name,
    email: user.email,
  };
}

async function authMiddleware(req, res, next) {
  try {
    const authHeader = req.headers.authorization || '';
    const [type, token] = authHeader.split(' ');

    if (type !== 'Bearer' || !token) {
      return res.status(401).json({
        message: 'Token ausente.',
      });
    }

    const decoded = jwt.verify(token, JWT_SECRET);
    req.userId = decoded.userId;
    next();
  } catch (error) {
    return res.status(401).json({
      message: 'Token inválido ou expirado.',
    });
  }
}

app.get('/api/health', (req, res) => {
  return res.status(200).json({
    status: 'ok',
    message: 'API do PIRPG funcionando.',
  });
});

app.post('/api/auth/register', async (req, res) => {
  try {
    const { name, email, password } = req.body;

    if (!name || !email || !password) {
      return res.status(400).json({
        message: 'Nome, e-mail e senha são obrigatórios.',
      });
    }

    const normalizedName = String(name).trim();
    const normalizedEmail = String(email).trim().toLowerCase();
    const normalizedPassword = String(password);

    if (!normalizedEmail.includes('@')) {
      return res.status(400).json({
        message: 'E-mail inválido.',
      });
    }

    if (normalizedPassword.length < 6) {
      return res.status(400).json({
        message: 'A senha deve ter no mínimo 6 caracteres.',
      });
    }

    const existingUser = await User.findOne({ email: normalizedEmail });

    if (existingUser) {
      return res.status(409).json({
        message: 'Este e-mail já está cadastrado.',
      });
    }

    const passwordHash = await bcrypt.hash(normalizedPassword, 10);

    const user = await User.create({
      name: normalizedName,
      email: normalizedEmail,
      password: passwordHash,
    });

    const token = generateToken(user._id.toString());

    return res.status(201).json({
      message: 'Usuário cadastrado com sucesso.',
      token,
      user: serializeUser(user),
    });
  } catch (error) {
    if (error && error.code === 11000) {
      return res.status(409).json({
        message: 'Este e-mail já está cadastrado.',
      });
    }

    console.error('Erro no register:', error);

    return res.status(500).json({
      message: 'Erro interno do servidor ao cadastrar usuário.',
    });
  }
});

app.post('/api/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        message: 'E-mail e senha são obrigatórios.',
      });
    }

    const normalizedEmail = String(email).trim().toLowerCase();
    const normalizedPassword = String(password);

    const user = await User.findOne({ email: normalizedEmail });

    if (!user) {
      return res.status(401).json({
        message: 'E-mail ou senha inválidos.',
      });
    }

    const passwordMatches = await bcrypt.compare(
      normalizedPassword,
      user.password
    );

    if (!passwordMatches) {
      return res.status(401).json({
        message: 'E-mail ou senha inválidos.',
      });
    }

    const token = generateToken(user._id.toString());

    return res.status(200).json({
      message: 'Login realizado com sucesso.',
      token,
      user: serializeUser(user),
    });
  } catch (error) {
    console.error('Erro no login:', error);

    return res.status(500).json({
      message: 'Erro interno do servidor ao fazer login.',
    });
  }
});

app.get('/api/auth/me', authMiddleware, async (req, res) => {
  try {
    const user = await User.findById(req.userId).select('_id name email gameState');

    if (!user) {
      return res.status(404).json({
        message: 'Usuário não encontrado.',
      });
    }

    return res.status(200).json({
      user: serializeUser(user),
      gameState: user.gameState,
    });
  } catch (error) {
    console.error('Erro no /me:', error);

    return res.status(500).json({
      message: 'Erro interno do servidor ao carregar usuário.',
    });
  }
});

app.get('/api/game/state', authMiddleware, async (req, res) => {
  try {
    const user = await User.findById(req.userId).select('gameState');
    if (!user) {
      return res.status(404).json({ message: 'Usuário não encontrado.' });
    }
    
    return res.status(200).json(user.gameState || {});
  } catch (error) {
    console.error('Erro ao buscar estado do jogo:', error);
    return res.status(500).json({ message: 'Erro ao buscar estado do jogo.' });
  }
});

app.put('/api/game/state', authMiddleware, async (req, res) => {
  try {
    const user = await User.findById(req.userId);
    if (!user) {
      return res.status(404).json({ message: 'Usuário não encontrado.' });
    }
    
    const { hp, maxHp, currentPhase, inventory, defeatedPhases } = req.body;
    
    // Atualiza apenas os campos permitidos
    user.gameState = {
      hp: hp !== undefined ? hp : user.gameState.hp,
      maxHp: maxHp !== undefined ? maxHp : user.gameState.maxHp,
      currentPhase: currentPhase !== undefined ? currentPhase : user.gameState.currentPhase,
      inventory: inventory !== undefined ? inventory : user.gameState.inventory,
      defeatedPhases: defeatedPhases !== undefined ? defeatedPhases : user.gameState.defeatedPhases,
    };
    
    await user.save();
    
    return res.status(200).json({
      message: 'Estado do jogo atualizado com sucesso.',
      gameState: user.gameState
    });
  } catch (error) {
    console.error('Erro ao atualizar estado do jogo:', error);
    return res.status(500).json({ message: 'Erro ao atualizar estado do jogo.' });
  }
});

if (!MONGO_URI) {
  console.error('Defina MONGO_URI no arquivo .env (ou nas variáveis da Vercel)');
}
if (!JWT_SECRET) {
  console.error('Defina JWT_SECRET no arquivo .env (ou nas variáveis da Vercel)');
}

if (MONGO_URI) {
  mongoose.connect(MONGO_URI)
    .then(() => console.log('MongoDB conectado com sucesso.'))
    .catch((err) => console.error('Erro ao conectar ao MongoDB:', err));
}

if (process.env.NODE_ENV !== 'production') {
  app.listen(PORT, '0.0.0.0', () => {
    console.log(`Servidor rodando em http://0.0.0.0:${PORT}`);
  });
}

// Exporta o app para o Vercel Serverless Functions
module.exports = app;