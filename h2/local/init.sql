-- http://db.localhost

-- RUNSCRIPT FROM '/var/local/init.sql' ;

create schema if not exists base;

create table base.produto (
  id integer not null,
  nome varchar(30) not null,
  primary key (id)
);

insert into base.produto (id, nome) values
(1, 'feijão');
