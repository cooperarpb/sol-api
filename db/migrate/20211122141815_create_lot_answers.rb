class CreateLotAnswers < ActiveRecord::Migration[5.2]
  def change
    create_table :lot_answers do |t|
      t.references :lot_question, foreign_key: true, index: true
      t.references :user, foreign_key: true, index: true
      t.text :answer

      t.timestamps
    end
  end
end
