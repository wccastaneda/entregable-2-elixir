defmodule Library do

  defstruct data: [], users: []

  def new do
    %Library{
      data: [
        %{id: 1, name: "El Padrino", isbn: "9780582402416", available: "available"},
        %{id: 2, name: "Moby-Dick", isbn: "9788483087565", available: "NOT_available"}
      ],
      users: [
        %{id: 1, username: "pedrito", rented_books: []},
        %{id: 1, username: "marianita", rented_books: []}
      ]
    }
  end

  def run do
    db = new();
    loop(db)
  end

  defp loop(db) do
    IO.puts("""
    \-----------\---------------\------------
    Gestor de Inventario:
    1. Agregar libro
    2. Listar libros disponibles
    3. Validar disponibilidad de un libro por su ISBN
    4. Registrar un usuario en biblioteca
    5. Listar usuarios registrados
    6. Prestar un libro
    7. Devolver libro
    8. Listar libros prestados a un usuario
    """)
    
    IO.write("Seleccione una opción:")
    option = IO.gets("") |> String.trim() |> String.to_integer()

    case option do
      1 ->
        IO.write("Ingrese el nombre del libro:")
        name = IO.gets("") |> String.trim()
        IO.write("Ingrese el ISBN: ")
        isbn = IO.gets("") |> String.trim()
        db = add_book(db, name, isbn)
        loop(db)

      2 ->
        Enum.each(db.data, fn book ->
          IO.puts("#{book.id}. #{book.name}. #{book.isbn}. #{book.available}.")
        end)
        loop(db)

      3 ->
        IO.write("Ingrese el ISBN del libro:")
        isbn = IO.gets("") |> String.trim()
        find_book_by_isbn(db, isbn)
        loop(db)

      4 ->
        IO.write("Ingrese un nombre de usuario:")
        username = IO.gets("") |> String.trim()
        db = add_user(db, username)
        loop(db)

      5 ->
        Enum.each(db.users, fn user ->
          IO.puts("#{user.id}. #{user.username}.")
        end)
        loop(db)

      6 ->
        IO.write("Ingrese el ISBN del libro:")
        isbn = IO.gets("") |> String.trim()
        IO.write("Ingrese su usuario:")
        username = IO.gets("") |> String.trim()
        db = rent_book(db, isbn, username)
        loop(db)

      _ ->
        IO.puts("Opción no válida.")
        loop(task_manager)
    end
  end

  def add_book(%Library{} = library, name, isbn) do
    id = Enum.count(library.data) + 1
    book = %{id: id, name: name, isbn: isbn}
    %Library{library | data: library.data ++ [book]}
  end

  def find_book_by_isbn(%Library{} = library, isbn) do
    Enum.find(library.data, fn book -> Map.get(book, :isbn) == isbn end)
    |> IO.inspect()
  end

  def add_user(%Library{} = library, username) do
    id = Enum.count(library.users) + 1
    user = %{id: id, username: username, rented_books: []}
    %Library{library | users: library.users ++ [user]}
  end

  def rent_book(%Library{} = library, isbn, username) do
    with book <- find_book_by_isbn(library, isbn, "internal_logic"),
         {:ok, true} <- book_available?(book) do
      change_disponibility(library, isbn)
      |> block_book(library, isbn)
      |> mark_user(username, isbn)
      else
      error ->
        IO.inspect("BOOK---IS---ALREADY---RENTED")
        library
    end
  end

  defp book_available?(%{available: "available"} = book) do
    {:ok, true}
  end

  defp book_available?(%{available: "NOT_available"} = book) do
    {:error, :book_not_available}
  end

  defp change_disponibility(%Library{} = library, isbn) do
    book = find_book_by_isbn(library, isbn, "internal_logic")
    modified_book = %{book | available: "NOT_available"}
  end

  defp block_book(modified_book, %Library{} = library, isbn) do
    new_data = Enum.map(library.data, fn book ->
      if book.isbn == isbn, do: modified_book, else: book end
    )
    %Library{library | data: new_data}
  end

  defp mark_user(%Library{} = library, username, isbn) do
    book = find_book_by_isbn(library, isbn, "internal_logic")
    new_users_list = Enum.map(library.users, fn user ->
    if user.username == username, do: modify_user_rented_booklist(user, book), else: user end
    )
    %Library{library | users: new_users_list}
  end

  defp modify_user_rented_booklist(%{} = user, %{} = book) do
    %{user | rented_books: user.rented_books ++ [book]}
  end

  defp find_book_by_isbn(%Library{} = library, isbn, "internal_logic") do
    Enum.find(library.data, fn book -> Map.get(book, :isbn) == isbn end)
  end
end

Library.run()
