##
# WALKTHROUGH:
# First, I filled in the empty tests to prove the unoptimized code works as
# intended and got them all passing.
#
# Then, to make sure I fully understood what the code was doing, I combined our two # loops through 'dinos'. I focused on creating the 'health', 'comment', and 
# 'age_metrics' keys based on the data in the existing keys. I also changed the 
# single-letter variable to 'dino' and updated 'run' to 'assess_dinos'.
#
# Next, I focused on converting to an object-oriented approach. I created a Dinos 
# class and a DinoManagement class. Tests also got updated to instantiate 
# DinoManagement where needed.
#
# I've also added TODO comments to reflect where I'd ask reviewers in a pull 
# request (or maybe snag someone sooner, depending on team culture) to see if they # have knowledge of what the userbase does with this output, and/or their opinions # on how we might make certain attribute names more descriptive. Those comments 
# would be removed from the code once I had them written on the PR.
#
# In a more real-world scenario, I'd give more descriptive names to 'comment' and 
# 'age_metrics' (and honestly probably 'summary') after investigating how those 
# data points are used in a wider context.
# I also wouldn't keep this code in a single file. I'd likely have one for the Dino # class, one for Dino_Management, and one for the tests.


class Dino
  attr_accessor :name, :category, :period, :diet, :age, :health, :comment, :age_metrics

  def initialize(characteristics)
    @name = characteristics['name']
    @category = characteristics['category']
    @period = characteristics['period']
    @diet = characteristics['diet']
    @age = characteristics['age']
    @health = calculate_health
    @comment = create_comment
    @age_metrics = determine_age_metrics
  end

  def calculate_health
    return 0 if age <= 0

    base_health = 100 - age
    # if dinos aren't eating what they should, they lose health
    if category == 'herbivore'
      diet == 'plants' ? base_health : base_health / 2
    elsif category == 'carnivore'
      diet == 'meat' ? base_health : base_health / 2
    else
      0
    end
  end

  ##
  # TODO: Check w/team in PR - does anyone know how this is
  # used by internal/external users? Are we safe to give it
  # a more descriptive name than just 'comment', or even
  # make it an 'alive' boolean? --NMA 2024-10-05
  def create_comment
    health > 0 ? 'Alive' : 'Dead'
  end

  ##
  # TODO: Similarly, future PR question - does anyone know how
  # this is used/can we give it a more descriptive name
  # than 'age_metrics'? --NMA 2024-10-05
  def determine_age_metrics
    return 0 if comment == 'Dead'

  ##
  # TODO: Do we want this to be 0 if age == 1? That's what
  # it'll be right now. --NMA 2024-10-05
    age > 1 ? (age / 2).to_i : 0
  end
end

class DinoManagement
  attr_accessor :dinos

  def initialize(dinos)
    @dinos = dinos.nil? ? [] : dinos.map { |dino_characteristics| Dino.new(dino_characteristics) }
  end

  def assess_dinos
    { dinos: dinos_hash, summary: category_summary }
  end

  private

  def category_summary
    dinos.group_by(&:category).transform_values(&:count)
  end

  ##
  # Creates hash for output - placed here so it can be
  # private and keep the Dino class single-responsibility
  def dinos_hash
    dinos.map do |dino|
    {
      'name' => dino.name,
      'category' => dino.category,
      'period' => dino.period,
      'diet' => dino.diet,
      'age' => dino.age,
      'health' => dino.health,
      'comment' => dino.comment,
      'age_metrics' => dino.age_metrics
    }
    end
  end
end

dino_info = DinoManagement.new([
                                 { 'name' => 'DinoA', 'category' => 'herbivore', 'period' => 'Cretaceous',
                                   'diet' => 'plants', 'age' => 100 },
                                 { 'name' => 'DinoB', 'category' => 'carnivore', 'period' => 'Jurassic',
                                   'diet' => 'meat', 'age' => 80 }
                               ]).assess_dinos

puts dino_info

require 'rspec'

describe 'Dino Management' do
  let(:dino_data) do
    [
      { 'name' => 'DinoA', 'category' => 'herbivore', 'period' => 'Cretaceous', 'diet' => 'plants', 'age' => 100 },
      { 'name' => 'DinoB', 'category' => 'carnivore', 'period' => 'Jurassic', 'diet' => 'meat', 'age' => 80 }
    ]
  end

  let(:result) { DinoManagement.new(dino_data).assess_dinos }
  
  context 'when using improved method' do
    describe 'dino health calculation' do
      it 'calculates dino health based on age, category, and diet' do
        expect(result[:dinos][0]['health']).to eq(0)
        expect(result[:dinos][1]['health']).to eq(20)
      end
    end

    describe 'dino comment setting' do
      it 'assigns appropriate comment based on health' do
        expect(result[:dinos][0]['comment']).to eq('Dead')
        expect(result[:dinos][1]['comment']).to eq('Alive')
      end
    end

    describe 'dino age metric calculation' do
      it 'calculates age_metrics based on age and comment' do
        expect(result[:dinos][0]['age_metrics']).to eq(0)
        expect(result[:dinos][1]['age_metrics']).to eq(40)
      end
    end

    describe 'dino category summary' do
      it 'counts dinos by category' do
        summary = result[:summary]
        expect(summary['herbivore']).to eq(1)
        expect(summary['carnivore']).to eq(1)
      end

      it 'returns empty results if no dinos' do
        empty_result = DinoManagement.new([]).assess_dinos
        expect(empty_result[:dinos]).to eq([])
        expect(empty_result[:summary]).to eq({})
      end

      it 'correctly counts multiple dinos in the same category' do
          dino_data = [
            { 'name' => 'Yoshi', 'category' => 'herbivore', 'period' => 'Cretaceous', 'diet' => 'plants', 'age' => 10 },
            { 'name' => 'Littlefoot', 'category' => 'herbivore', 'period' => 'Cretaceous', 'diet' => 'plants', 'age' => 5 }
          ]
          result = DinoManagement.new(dino_data).assess_dinos
          expect(result[:summary]['herbivore']).to eq(2)
        end
    end

    describe 'dino_data is nil' do
      it 'returns empty results' do
        result = DinoManagement.new(nil).assess_dinos
        expect(result[:dinos]).to eq([])
        expect(result[:summary]).to eq({})
      end
    end

    describe 'dino edge case ages' do
      it 'calculates health and comment for a dino with age zero' do
        result = DinoManagement.new([{ 'name' => 'Baby Sinclair', 'category' => 'herbivore', 'period' => 'Cretaceous', 'diet' => 'plants', 'age' => 0 }]).assess_dinos
        expect(result[:dinos][0]['health']).to eq(0)
        expect(result[:dinos][0]['age_metrics']).to eq(0)
        expect(result[:dinos][0]['comment']).to eq('Dead')
      end

      it 'calculates health and comment for a dino with negative age' do
        result = DinoManagement.new([{ 'name' => 'Chicago "Sue" Field', 'category' => 'carnivore', 'period' => 'Jurassic', 'diet' => 'meat', 'age' => -5 }]).assess_dinos
        expect(result[:dinos][0]['health']).to eq(0)
        expect(result[:dinos][0]['age_metrics']).to eq(0)
        expect(result[:dinos][0]['comment']).to eq('Dead')
      end

      it 'calculates health, comment, and metrics for a dino with an age of 1' do
        result = DinoManagement.new([{ 'name' => 'Barney', 'category' => 'carnivore', 'period' => 'Cretaceous', 'diet' => 'meat', 'age' => 1 }]).assess_dinos
        expect(result[:dinos][0]['health']).to eq(99)
        expect(result[:dinos][0]['age_metrics']).to eq(0)
        expect(result[:dinos][0]['comment']).to eq('Alive')
      end
    end

    describe 'dino edge case category or diet' do
      it 'calculates health and comment for a dino with an unrecognized category' do
        result = DinoManagement.new([{ 'name' => 'Bowser', 'category' => 'omnivore', 'period' => 'Cretaceous', 'diet' => 'plants', 'age' => 35 }]).assess_dinos
        expect(result[:dinos][0]['health']).to eq(0)
        expect(result[:dinos][0]['comment']).to eq('Dead')
      end

      it 'calculates health and comment for a dino with an unrecognized diet' do
        result = DinoManagement.new([{ 'name' => 'Earl Sinclair', 'category' => 'carnivore', 'period' => 'Jurassic', 'diet' => 'pizza', 'age' => 40 }]).assess_dinos
        expect(result[:dinos][0]['health']).to eq(30)
        expect(result[:dinos][0]['comment']).to eq('Alive')
      end
    end
  end
end
