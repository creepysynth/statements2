--1. Вывести все товары и категорию, в которой они находятся.
SELECT item.item_name, category.category_title FROM item NATURAL JOIN category;

--2. Вывести все товары из конкретного заказа.
SELECT item.item_name FROM item NATURAL JOIN item__order WHERE item__order.order_id = ?;

--3. Вывести все заказы с конкретной единицей товара.
SELECT * FROM item__order NATURAL JOIN "order" WHERE item__order.item_id = ?;

--4. Вывести все товары, заказанные за последний час.
SELECT item.item_name FROM item NATURAL JOIN item__order NATURAL JOIN "order"
    WHERE "order".order_created > NOW() - INTERVAL '1 hour';

--5. Вывести все товары, заказанные за сегодня.
SELECT item.item_name FROM item NATURAL JOIN item__order NATURAL JOIN "order"
    WHERE "order".order_created > TIMESTAMP 'today';

--6. Вывести все товары, заказанные за вчера.
SELECT item.item_name FROM item NATURAL JOIN item__order
    NATURAL JOIN "order" WHERE "order".order_created BETWEEN TIMESTAMP 'yesterday' AND TIMESTAMP 'today';

--7. Вывести все товары из заданной категории, заказанные за последний час.
SELECT item.item_name FROM item NATURAL JOIN item__order NATURAL JOIN "order"
    NATURAL JOIN category WHERE "order".order_created > NOW() - INTERVAL '1 hour' AND category.category_title = 'Tools';

--8. Вывести все товары из заданной категории, заказанные за сегодня.
SELECT item.item_name FROM item NATURAL JOIN item__order NATURAL JOIN "order"
    NATURAL JOIN category WHERE "order".order_created > TIMESTAMP 'today' AND category.category_title = 'Tools';

--9. Вывести все товары из заданной категории, заказанные за вчера.
SELECT item.item_name FROM item NATURAL JOIN item__order NATURAL JOIN "order"
    NATURAL JOIN category WHERE "order".order_created BETWEEN TIMESTAMP 'yesterday' AND TIMESTAMP 'today'
    AND category.category_title = 'Tools';

--10. Вывести все товары, названия которых начинаются с заданной последовательности букв (см. LIKE).
SELECT item_name FROM item WHERE item_name LIKE '?%' ORDER BY item_name;

--11. Вывести все товары, названия которых заканчиваются заданной последовательностью букв (см. LIKE).
SELECT item_name FROM item WHERE item_name LIKE '%?' ORDER BY item_name;

--12. Вывести все товары, названия которых содержат заданные последовательности букв (см. LIKE).
SELECT item_name FROM item WHERE item_name LIKE '%?%' ORDER BY item_name;

--13. Вывести список категорий и количество товаров в каждой категории.
SELECT category.category_title, count(item.category_id) FROM category 
    LEFT JOIN item ON category.category_id = item.item_id GROUP BY category.category_id;

--14. Вывести список всех заказов и количество товаров в каждом.
SELECT "order".order_id, "order".order_address, count(item__order.item__order_quantity) FROM "order"
    LEFT JOIN item__order ON "order".order_id = item__order.order_id
    GROUP BY "order".order_id ORDER BY "order".order_id;

--15. Вывести список всех товаров и количество заказов, в которых имеется этот товар.
SELECT item.item_name, count(item__order.order_id) FROM item
    LEFT JOIN item__order ON item.item_id = item__order.item_id
    GROUP BY item.item_name ORDER BY item.item_name;

--16. Вывести список заказов, упорядоченный по дате заказа и суммарную стоимость товаров в каждом из них.
SELECT "order".order_id, "order".order_address, sum(item.item_price * item__order.item__order_quantity) FROM "order"
    LEFT JOIN item__order ON item__order.order_id = "order".order_id
    LEFT JOIN item ON item__order.item_id = item.item_id
    GROUP BY "order".order_id ORDER BY "order".order_created;

--17. Вывести список товаров, цену, количество и суммарную стоимость каждого из них в заказе с заданным ID.
SELECT item.item_name, item.item_price, sum(item__order.item__order_quantity),
    item.item_price*item__order.item__order_quantity AS total_price FROM item 
    LEFT JOIN item__order ON item.item_id = item__order.item_id WHERE item__order.order_id = ?
    GROUP BY item.item_id, item__order.item__order_quantity;

--18. Для заданного ID заказа вывести список категорий, товары из которых присутствуют в этом заказе. Для каждой из категорий вывести суммарное количество и суммарную стоимость товаров.
SELECT "order".order_id, category.category_title, count(item.item_id), sum(item.item_price) FROM "order" 
    LEFT JOIN item__order ON "order".order_id = item__order.order_id 
    LEFT JOIN item ON item__order.item_id = item.item_id 
    LEFT JOIN category ON item.category_id = category.category_id 
    WHERE "order".order_id = ? GROUP BY "order".order_id, category.category_title;

--19. Вывести список клиентов, которые заказывали товары из категории с заданным ID за последние 3 дня.
SELECT customer.customer_name FROM category 
    NATURAL JOIN item 
    NATURAL JOIN item__order 
    NATURAL JOIN "order" 
    NATURAL JOIN customer 
    WHERE category.category_id = ? AND "order".order_created > TIMESTAMP 'today' - INTERVAL '48 hours'
    GROUP BY customer.customer_name;

--20. Вывести имена всех клиентов, производивших заказы за последние сутки.
SELECT customer.customer_name FROM customer NATURAL JOIN "order"
    WHERE "order".order_created > NOW() - INTERVAL '24 hours';

--21. Вывести всех клиентов, производивших заказы, содержащие товар с заданным ID.
SELECT customer.customer_name FROM item__order
    NATURAL JOIN "order"
    NATURAL JOIN customer
    WHERE item__order.item_id = ?;

--22. Для каждой категории вывести урл загрузки изображения с именем category_image в формате 'http://img.domain.com/category/<category_id>.jpg' для включенных категорий, и 'http://img.domain.com/category/<category_id>_disabled.jpg' для выключеных.
SELECT *, CASE 
    WHEN (category.category_enabled = 't')
    THEN format('http://img.domain.com/category/%s.jpg', category.category_id)
    ELSE format('http://img.domain.com/category/%s_disabled.jpg', category.category_id)
    END AS category_image FROM category;

--23. Для товаров, которые были заказаны за все время во всех заказах общим количеством более X единиц, установить item_popular = TRUE, для остальных — FALSE.
WITH t AS (UPDATE item SET item_popular = FALSE) 
UPDATE item SET item_popular = TRUE 
    FROM (SELECT item_id, sum(item__order_quantity) FROM item__order GROUP BY item_id) AS temp
    WHERE item.item_id = temp.item_id AND temp.sum > ?;

--24. Одним запросом для указанных ID категорий установить флаг category_enabled = TRUE, для остальных — FALSE. Не применять WHERE.
UPDATE category SET category_enabled = category_id IN (?);