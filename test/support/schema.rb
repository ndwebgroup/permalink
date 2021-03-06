ActiveRecord::Schema.define(:version => 0) do
  create_table :posts do |t|
    t.string :title, :permalink, :description, :slug
    t.belongs_to :user
  end

  create_table :users do |t|
    t.string :name, :permalink, :slug
  end

  create_table :admin_users do |t|
    t.string :name, :permalink, :slug
    t.boolean :is_super
  end
end
