// SUGGESTED BACKEND IMPROVEMENTS
// Add these endpoints to your upload.js file

// 1. GET endpoints for fetching data
router.get('/products', async (req, res) => {
  try {
    const result = await dynamo.scan({ TableName: tables.products }).promise();
    res.json({ products: result.Items });
  } catch (err) {
    console.error(err);
    res.status(500).send('Failed to fetch products');
  }
});

router.get('/banners', async (req, res) => {
  try {
    const result = await dynamo.scan({ TableName: tables.banners }).promise();
    res.json({ banners: result.Items });
  } catch (err) {
    console.error(err);
    res.status(500).send('Failed to fetch banners');
  }
});

router.get('/categories', async (req, res) => {
  try {
    const result = await dynamo.scan({ TableName: tables.category }).promise();
    res.json({ categories: result.Items });
  } catch (err) {
    console.error(err);
    res.status(500).send('Failed to fetch categories');
  }
});

// 2. UPDATE endpoints
router.put('/products/:id', upload.single('image'), async (req, res) => {
  try {
    const { id } = req.params;
    const { category, desc, name, new_price, old_price, quantity, season, type } = req.body;
    
    let imageVariants = null;
    if (req.file) {
      imageVariants = await uploadAndResizeToS3(req.file.buffer, id);
    }

    const item = {
      id,
      category,
      desc,
      name,
      new_price: Number(new_price),
      old_price: Number(old_price),
      quantity: Number(quantity),
      season,
      type,
      updatedAt: Date.now(),
    };

    if (imageVariants) {
      item.image = imageVariants;
    }

    await saveToDynamoAndRedis(tables.products, item, `product:${id}`);
    res.json(item);
  } catch (err) {
    console.error(err);
    res.status(500).send('Product update failed');
  }
});

router.put('/banners/:id', upload.single('image'), async (req, res) => {
  try {
    const { id } = req.params;
    const { category, title } = req.body;
    
    let imageVariants = null;
    if (req.file) {
      imageVariants = await uploadAndResizeToS3(req.file.buffer, id);
    }

    const item = {
      id,
      category,
      title,
      updatedAt: Date.now(),
    };

    if (imageVariants) {
      item.image = imageVariants;
    }

    await saveToDynamoAndRedis(tables.banners, item, `banner:${id}`);
    res.json(item);
  } catch (err) {
    console.error(err);
    res.status(500).send('Banner update failed');
  }
});

router.put('/categories/:id', upload.single('image'), async (req, res) => {
  try {
    const { id } = req.params;
    const { name, priority } = req.body;
    
    let imageVariants = null;
    if (req.file) {
      imageVariants = await uploadAndResizeToS3(req.file.buffer, id);
    }

    const item = {
      id,
      name,
      priority: Number(priority),
      updatedAt: Date.now(),
    };

    if (imageVariants) {
      item.image = imageVariants;
    }

    await saveToDynamoAndRedis(tables.category, item, `category:${id}`);
    res.json(item);
  } catch (err) {
    console.error(err);
    res.status(500).send('Category update failed');
  }
});

// 3. DELETE endpoints
router.delete('/products/:id', async (req, res) => {
  try {
    const { id } = req.params;
    await dynamo.delete({ TableName: tables.products, Key: { id } }).promise();
    await redis.del(`product:${id}`);
    res.status(204).send();
  } catch (err) {
    console.error(err);
    res.status(500).send('Product deletion failed');
  }
});

router.delete('/banners/:id', async (req, res) => {
  try {
    const { id } = req.params;
    await dynamo.delete({ TableName: tables.banners, Key: { id } }).promise();
    await redis.del(`banner:${id}`);
    res.status(204).send();
  } catch (err) {
    console.error(err);
    res.status(500).send('Banner deletion failed');
  }
});

router.delete('/categories/:id', async (req, res) => {
  try {
    const { id } = req.params;
    await dynamo.delete({ TableName: tables.category, Key: { id } }).promise();
    await redis.del(`category:${id}`);
    res.status(204).send();
  } catch (err) {
    console.error(err);
    res.status(500).send('Category deletion failed');
  }
});

// 4. Modified POST endpoints to match frontend expectations
router.post('/products', upload.single('image'), async (req, res) => {
  try {
    const { category, desc, name, newPrice, oldPrice, quantity, season, type } = req.body;
    const imageId = uuidv4();
    const variants = await uploadAndResizeToS3(req.file.buffer, imageId);

    const item = {
      id: imageId,
      category,
      desc,
      name,
      new_price: Number(newPrice),
      old_price: oldPrice ? Number(oldPrice) : null,
      quantity: Number(quantity),
      season,
      type,
      image: variants,
      createdAt: Date.now(),
    };

    await saveToDynamoAndRedis(tables.products, item, `product:${imageId}`);
    res.json(item);
  } catch (err) {
    console.error(err);
    res.status(500).send('Product upload failed');
  }
});

router.post('/banners', upload.single('image'), async (req, res) => {
  try {
    const { name } = req.body;
    const imageId = uuidv4();
    const variants = await uploadAndResizeToS3(req.file.buffer, imageId);

    const item = {
      id: imageId,
      name,
      image: variants,
      isActive: true,
      createdAt: Date.now(),
    };

    await saveToDynamoAndRedis(tables.banners, item, `banner:${imageId}`);
    res.json(item);
  } catch (err) {
    console.error(err);
    res.status(500).send('Banner upload failed');
  }
});

router.post('/categories', upload.single('image'), async (req, res) => {
  try {
    const { name, description } = req.body;
    const imageId = uuidv4();
    const variants = await uploadAndResizeToS3(req.file.buffer, imageId);

    const item = {
      id: imageId,
      name,
      description,
      image: variants,
      isActive: true,
      createdAt: Date.now(),
    };

    await saveToDynamoAndRedis(tables.category, item, `category:${imageId}`);
    res.json(item);
  } catch (err) {
    console.error(err);
    res.status(500).send('Category upload failed');
  }
}); 