defmodule ElixirPhx.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false

  @primary_key {:id, :id, autogenerate: true}
  @derive {JSON.Encoder, only: [:id, :first_name, :last_name, :inserted_at, :updated_at]}

  schema "users" do
    field :first_name, :string
    field :last_name, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name])
    |> validate_required([:first_name, :last_name])
    |> validate_length(:first_name, min: 1, max: 255)
    |> validate_length(:last_name, min: 1, max: 255)
  end

  @doc """
  Gets all users from the database.
  """
  def list_users do
    ElixirPhx.Repo.all(__MODULE__)
  end

  @doc """
  Gets a single user by id.

  Returns `nil` if the User does not exist.

  ## Examples

      iex> get_user(123)
      %User{}

      iex> get_user(456)
      nil

  """
  def get_user(id) when is_binary(id) do
    case Integer.parse(id) do
      {int_id, ""} -> get_user(int_id)
      _ -> nil
    end
  end

  def get_user(id) when is_integer(id) do
    ElixirPhx.Repo.get(__MODULE__, id)
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %__MODULE__{}
    |> changeset(attrs)
    |> ElixirPhx.Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%__MODULE__{} = user, attrs) do
    user
    |> changeset(attrs)
    |> ElixirPhx.Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%__MODULE__{} = user) do
    ElixirPhx.Repo.delete(user)
  end
end
