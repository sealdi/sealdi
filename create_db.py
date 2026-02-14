"""Script para crear una base de datos SQLite simple con datos de ejemplo."""
from __future__ import annotations

import sqlite3
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, Sequence

DB_FILENAME = "tienda.db"
DB_PATH = Path(__file__).with_name(DB_FILENAME)


@dataclass(frozen=True)
class Customer:
    nombre: str
    correo: str


@dataclass(frozen=True)
class Product:
    nombre: str
    precio: float


@dataclass(frozen=True)
class Order:
    customer_email: str
    product_name: str
    cantidad: int


def get_connection(db_path: Path = DB_PATH) -> sqlite3.Connection:
    """Crea una conexión a la base de datos y habilita las claves foráneas."""
    connection = sqlite3.connect(db_path)
    connection.execute("PRAGMA foreign_keys = ON;")
    return connection


def reset_schema(connection: sqlite3.Connection) -> None:
    """Elimina las tablas si existen y las vuelve a crear."""
    connection.executescript(
        """
        DROP TABLE IF EXISTS pedidos;
        DROP TABLE IF EXISTS productos;
        DROP TABLE IF EXISTS clientes;

        CREATE TABLE clientes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            correo TEXT NOT NULL UNIQUE
        );

        CREATE TABLE productos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            precio REAL NOT NULL CHECK(precio >= 0)
        );

        CREATE TABLE pedidos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            cliente_id INTEGER NOT NULL,
            producto_id INTEGER NOT NULL,
            cantidad INTEGER NOT NULL CHECK(cantidad > 0),
            fecha_creacion TEXT NOT NULL DEFAULT (datetime('now')),
            FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE CASCADE,
            FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE CASCADE
        );
        """
    )


def insert_data(
    connection: sqlite3.Connection,
    customers: Iterable[Customer],
    products: Iterable[Product],
    orders: Iterable[Order],
) -> None:
    """Inserta datos de ejemplo en la base de datos."""
    cursor = connection.cursor()

    cursor.executemany(
        "INSERT INTO clientes (nombre, correo) VALUES (?, ?)",
        ((customer.nombre, customer.correo) for customer in customers),
    )

    cursor.executemany(
        "INSERT INTO productos (nombre, precio) VALUES (?, ?)",
        ((product.nombre, product.precio) for product in products),
    )

    cursor.executemany(
        """
        INSERT INTO pedidos (cliente_id, producto_id, cantidad)
        VALUES (
            (SELECT id FROM clientes WHERE correo = ?),
            (SELECT id FROM productos WHERE nombre = ?),
            ?
        )
        """,
        (
            (order.customer_email, order.product_name, order.cantidad)
            for order in orders
        ),
    )

    connection.commit()


def fetch_all(connection: sqlite3.Connection, query: str) -> Sequence[sqlite3.Row]:
    """Ejecuta una consulta y devuelve todas las filas con acceso por nombre de columna."""
    connection.row_factory = sqlite3.Row
    cursor = connection.execute(query)
    return cursor.fetchall()


def main() -> None:
    """Punto de entrada del script."""
    customers = (
        Customer("Ana Pérez", "ana@example.com"),
        Customer("Luis García", "luis@example.com"),
    )

    products = (
        Product("Café en grano 1kg", 12.5),
        Product("Taza reutilizable", 8.0),
        Product("Filtro metálico", 15.75),
    )

    orders = (
        Order("ana@example.com", "Café en grano 1kg", 2),
        Order("ana@example.com", "Taza reutilizable", 1),
        Order("luis@example.com", "Filtro metálico", 1),
    )

    connection = get_connection()
    try:
        reset_schema(connection)
        insert_data(connection, customers, products, orders)

        print(f"Base de datos creada en: {DB_PATH.resolve()}")
        print("Clientes registrados:")
        for row in fetch_all(connection, "SELECT nombre, correo FROM clientes"):
            print(f" - {row['nombre']} ({row['correo']})")

        print("\nPedidos registrados:")
        query = (
            "SELECT c.nombre as cliente, p.nombre as producto, pedidos.cantidad, pedidos.fecha_creacion "
            "FROM pedidos "
            "JOIN clientes c ON c.id = pedidos.cliente_id "
            "JOIN productos p ON p.id = pedidos.producto_id "
            "ORDER BY pedidos.id"
        )
        for row in fetch_all(connection, query):
            print(
                f" - {row['cliente']} pidió {row['cantidad']} x {row['producto']} el {row['fecha_creacion']}"
            )
    finally:
        connection.close()


if __name__ == "__main__":
    main()
