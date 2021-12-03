class CreateLotQuestions < ActiveRecord::Migration[5.2]
  def change
    create_table :lot_questions do |t|
      t.references :lot, foreign_key: true, index: true
      t.references :supplier, foreign_key: true, index: true
      t.references :user, foreign_key: true, index: true
      t.text :question
      t.text :answer

      t.timestamps
    end
  end
end
