const express = require('express');
const cors = require('cors');
const mysql = require('mysql2');
const path = require('path'); // Statik dosyaları sunabilmek için path modülünü kullanacağız

// Express app oluştur
const app = express();

// JSON formatında veri alabilmesi için middleware ekleyelim
app.use(express.json());

// CORS middleware'i kullanarak frontend uygulamalarıyla iletişim kurabilsin
app.use(cors());

// Statik dosya sunma işlemi (images klasöründeki dosyalar)
app.use('/images', express.static(path.join(__dirname, 'images')));

// MySQL bağlantısı
const db = mysql.createConnection({
  host: 'localhost',
  user: 'user',       // MySQL kullanıcı adınızı buraya yazın
  password: 'password', // MySQL şifrenizi buraya yazın
  database: 'database'  // Kullanıcı veritabanınızın adı
});

// MySQL bağlantısını kontrol et
db.connect((err) => {
  if (err) {
    console.error('MySQL bağlantı hatası:', err);
  } else {
    console.log('MySQL bağlantısı başarılı!');
  }
});

app.get('/', (req, res) => {
  res.send('Hello World!')
});

//users
app.get('/users/:id', (req, res) => {
  const id = req.params.id;
  db.execute('SELECT * FROM users WHERE id = ?', [id], (err, results) => {
    if (err) {
      return res.status(500).json({ message: 'Veritabanı hatası!' });
    }
    if (results.length > 0) {
      res.status(200).json(results[0]);
    } else {
      res.status(404).json({ message: 'Kullanıcı bulunamadı!' });
    }
  });
});

// Kullanıcı kayıt olma işlemi
app.post('/register', (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ message: 'Email ve şifre gerekli!' });
  }

  // Aynı email ile bir kullanıcı zaten kayıtlı mı kontrol et
  db.execute('SELECT * FROM users WHERE email = ?', [email], (err, results) => {
    if (err) {
      return res.status(500).json({ message: 'Veritabanı hatası!' });
    }

    if (results.length > 0) {
      return res.status(400).json({ message: 'Bu email ile bir kullanıcı zaten kayıtlı!' });
    }

    // Yeni kullanıcıyı veritabanına ekle
    db.execute('INSERT INTO users (email, password) VALUES (?, ?)', [email, password], (err, result) => {
      if (err) {
        return res.status(500).json({ message: 'Veritabanı hatası!' });
      }
      const userId = result[0].id;
      res.status(201).json({ message: 'Kullanıcı başarıyla kaydedildi!', email, userId });
    });
  });
});

// Kullanıcı giriş işlemi
app.post('/login', (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ message: 'Email ve şifre gerekli!' });
  }

  // Kullanıcıyı kontrol et
  db.execute('SELECT * FROM users WHERE email = ? AND password = ?', [email, password], (err, results) => {
    if (err) {
      return res.status(500).json({ message: 'Veritabanı hatası!' });
    }

    if (results.length > 0) {
      //user id
      const userId = results[0].id;
      res.status(200).json({ message: 'Kullanıcı başarıyla giriş yaptı!', userId });
    } else {
      res.status(401).json({ message: 'Geçersiz email veya şifre!' });
    }
  });
});

app.get('/getfilms/:id', (req, res) => {
  const userId = req.params.id;
  db.execute('SELECT * FROM films WHERE id NOT IN (SELECT film_id FROM orders WHERE user_id = ?)', [userId], (err, results) => {
    if (err) {
      return res.status(500).json({ message: 'Veritabanı hatası!' });
    }
    res.status(200).json(results);
  });
});

app.get('/films/:id', (req, res) => {
  const id = req.params.id;
  db.execute('SELECT * FROM films WHERE id = ?', [id], (err, results) => {
    if (err) {
      return res.status(500).json({ message: 'Veritabanı hatası!' });
    }
    if (results.length > 0) {
      res.status(200).json(results[0]);
    } else {
      res.status(404).json({ message: 'Film bulunamadı!' });
    }
  });
});

// Örnek Backend (Node.js - Express)
app.get('/purchased_films/:id', (req, res) => {
  const userId = req.params.id;
  db.execute('SELECT * FROM films WHERE id IN (SELECT film_id FROM orders WHERE user_id = ?)', [userId], (err, results) => {
    if (err) {
      return res.status(500).json({ message: 'Veritabanı hatası!' });
    }
    res.status(200).json(results);
  });
});

app.post('/orders', (req, res) => {
  const { userId, cartItems } = req.body;

  if (!userId || !cartItems || cartItems.length === 0) {
    return res.status(400).json({ message: 'Geçersiz veri. Kullanıcı ID ve ürün listesi gereklidir.' });
  }

  // Siparişi veritabanına ekle
  cartItems.forEach(item => {
    const { id: filmId, name, price } = item; // item'dan film bilgilerini alıyoruz
    const query = 'INSERT INTO orders (user_id, film_id) VALUES (?, ?)';

    db.execute(query, [userId, filmId], (err, results) => {
      if (err) {
        return res.status(500).json({ message: 'Veritabanı hatası!' });
      }

      // Eğer bütün siparişler eklenmişse, başarılı mesajı döneriz
      if (cartItems.indexOf(item) === cartItems.length - 1) {
        return res.status(201).json({ message: 'Sipariş başarıyla oluşturuldu!' });
      }
    });
  });
});

// Sunucu portu
const PORT = 3000;

// Sunucuyu başlat
app.listen(PORT, () => {
  console.log(`Sunucu http://localhost:${PORT} adresinde çalışıyor.`);
});
