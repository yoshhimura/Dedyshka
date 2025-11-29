-- DATABASE_SCHEMA.sql
-- Схема базы данных для системы "Умный список задач"

-- Создание таблицы категорий
CREATE TABLE categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    color TEXT DEFAULT '#CCCCCC'  -- HEX-цвет для визуального отображения категории
);

-- Создание таблицы задач
CREATE TABLE tasks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    description TEXT,
    priority TEXT CHECK(priority IN ('низкий', 'средний', 'высокий')) NOT NULL DEFAULT 'средний',
    category_id INTEGER,
    deadline DATETIME,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    is_completed BOOLEAN DEFAULT 0,

    -- Внешний ключ на categories.id
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL
);

-- Индексы для часто используемых полей

-- Индекс по приоритету и статусу завершённости (для фильтрации)
CREATE INDEX idx_tasks_priority_completed ON tasks (priority, is_completed);

-- Индекс по дедлайну (для сортировки и поиска ближайших задач)
CREATE INDEX idx_tasks_deadline ON tasks (deadline);

-- Индекс по категории (для быстрого фильтра по категориям)
CREATE INDEX idx_tasks_category_id ON tasks (category_id);

-- Индекс по дате создания (если нужно сортировать по новизне)
CREATE INDEX idx_tasks_created_at ON tasks (created_at);

-- Индекс для поиска по названию (часто используется в поиске)
CREATE INDEX idx_tasks_title ON tasks (title);


-- Примеры запросов для выборки данных

-- 1. Получить все активные (незавершённые) задачи с высоким приоритетом, отсортированные по дедлайну
SELECT t.id, t.title, t.description, t.priority, c.name AS category, t.deadline, t.created_at
FROM tasks t
LEFT JOIN categories c ON t.category_id = c.id
WHERE t.is_completed = 0 AND t.priority = 'высокий'
ORDER BY t.deadline ASC;

-- 2. Получить все задачи в категории "Работа", отсортированные по дате создания (новые сверху)
SELECT t.id, t.title, t.description, t.priority, c.name AS category, t.deadline, t.created_at
FROM tasks t
JOIN categories c ON t.category_id = c.id
WHERE c.name = 'Работа'
ORDER BY t.created_at DESC;

-- 3. Найти все задачи, у которых дедлайн сегодня или уже просрочен (и не завершены)
SELECT t.id, t.title, t.description, t.priority, c.name AS category, t.deadline, t.created_at
FROM tasks t
LEFT JOIN categories c ON t.category_id = c.id
WHERE t.deadline <= datetime('now') AND t.is_completed = 0
ORDER BY t.deadline ASC;