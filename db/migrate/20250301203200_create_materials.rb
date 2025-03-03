class CreateMaterials < ActiveRecord::Migration[8.0]
  def change
    create_table :materials do |t|
      t.string :title
      t.text :instruction
      t.string :file_url
      t.references :classroom, null: false, foreign_key: true

      t.timestamps
    end
  end
end
