class CreateMovies < ActiveRecord::Migration[7.2]
  def change
    create_table :movies do |t|
      t.string :title, null: false
      t.string :genre, null: false

      t.timestamps
    end
  end
end
