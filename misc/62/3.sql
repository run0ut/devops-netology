/* Таблица orders */
insert into orders (наименование, цена) values ('Шоколад', 10 );
insert into orders (наименование, цена) values ('Принтер', 3000 );
insert into orders (наименование, цена) values ('Книга', 500 );
insert into orders (наименование, цена) values ('Монитор', 7000);
insert into orders (наименование, цена) values ('Гитара', 4000);
/* Таблица clients */
insert into clients (фамилия, "страна проживания") values ('Иванов Иван Иванович', 'USA');
insert into clients (фамилия, "страна проживания") values ('Петров Петр Петрович', 'Canada');
insert into clients (фамилия, "страна проживания") values ('Иоганн Себастьян Бах', 'Japan');
insert into clients (фамилия, "страна проживания") values ('Ронни Джеймс Дио', 'Russia');
insert into clients (фамилия, "страна проживания") values ('Ritchie Blackmore', 'Russia');
/* вычислите количество записей для каждой таблицы */
select count(*) from orders;
select count(*) from clients;