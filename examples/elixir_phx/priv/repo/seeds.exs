# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     ElixirPhx.Repo.insert!(%ElixirPhx.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias ElixirPhx.{Repo, User}

# Clear existing users (useful for development)
Repo.delete_all(User)

# Create sample users
users = [
  %{first_name: "John", last_name: "Doe"},
  %{first_name: "Jane", last_name: "Smith"},
  %{first_name: "Alice", last_name: "Johnson"},
  %{first_name: "Bob", last_name: "Williams"},
  %{first_name: "Charlie", last_name: "Brown"}
]

Enum.each(users, fn user_attrs ->
  case User.create_user(user_attrs) do
    {:ok, user} ->
      IO.puts("Created user: #{user.first_name} #{user.last_name} (ID: #{user.id})")

    {:error, changeset} ->
      IO.puts("Failed to create user: #{inspect(changeset.errors)}")
  end
end)
