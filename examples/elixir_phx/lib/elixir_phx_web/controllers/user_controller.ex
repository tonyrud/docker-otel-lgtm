defmodule ElixirPhxWeb.UserController do
  use ElixirPhxWeb, :controller
  alias ElixirPhx.User
  require Logger

  @doc """
  Lists all users.
  """
  def index(conn, _params) do
    Logger.info("Listing all users", %{endpoint: "/users", method: "GET"})

    users = User.list_users()

    Logger.info("Retrieved users", %{count: length(users)})

    conn
    |> put_status(:ok)
    |> json(%{users: users})
  end

  @doc """
  Shows a specific user by ID.
  """
  def show(conn, %{"id" => id}) do
    Logger.info("Getting user by ID", %{user_id: id, endpoint: "/users/:id", method: "GET"})

    case User.get_user(id) do
      nil ->
        Logger.warning("User not found", %{user_id: id})

        conn
        |> put_status(:not_found)
        |> json(%{error: "User not found"})

      user ->
        Logger.info("User found", %{user_id: user.id})

        conn
        |> put_status(:ok)
        |> json(%{user: user})
    end
  end

  @doc """
  Creates a new user.
  """
  def create(conn, %{"user" => user_params}) do
    Logger.info("Creating new user", %{endpoint: "/users", method: "POST"})

    case User.create_user(user_params) do
      {:ok, user} ->
        Logger.info("User created successfully", %{user_id: user.id})

        conn
        |> put_status(:created)
        |> json(%{user: user})

      {:error, changeset} ->
        Logger.warning("User creation failed", %{errors: changeset.errors})

        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_changeset_errors(changeset)})
    end
  end

  def create(conn, _params) do
    Logger.warning("Invalid user creation request - missing user params")

    conn
    |> put_status(:bad_request)
    |> json(%{error: "Missing user parameters"})
  end

  # Helper function to format changeset errors
  defp format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
