/* создать таблицу orders */
create table orders (
    id serial primary key,
    наименование varchar(150),
    цена integer
);
/* создать таблицу clients*/
create table clients (
    id serial primary key,
    фамилия varchar(150),
    "страна проживания" varchar(150),
    заказ integer,
    foreign key (заказ) references orders (id)
);
/* создать пользователя test-simple-user */
create user "test-simple-user";
/* дать пользователям права по заданию */
grant all privileges on database test_db to "test-admin-user";
grant SELECT, INSERT, UPDATE, DELETE on orders to "test-simple-user";
grant SELECT, INSERT, UPDATE, DELETE on clients to "test-simple-user";
/* вывести список прав */
SELECT 
    grantee, table_name, privilege_type 
FROM 
    information_schema.table_privileges 
WHERE 
    grantee in ('test-admin-user','test-simple-user')
    and table_name in ('clients','orders')
order by 
    1,2,3;
