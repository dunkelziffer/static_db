class Shirt < ApplicationRecord
  enum :size, { small: "S", medium: "M", large: "L" }
end
