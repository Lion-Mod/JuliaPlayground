using Chain
using DataFrames
using Random

## COUNT NUMBER OF NUCLEOTIDES
function count_nucleotides(dna_string)
    """
    For a list of nucleotides in a dna_string count up the total number of each nucleotide.
    """
    df = DataFrame()
    df.dna_string = collect(dna_string)

    @chain df begin
        groupby(:dna_string)
        combine(nrow => :total_nucleotides)
    end

end


## HAMMING DISTANCE OF TWO DNA SEQUENCES
function hamming_distance_of_dna(dna_string_one, dna_string_two)
    """
    e.g. hamming distance of 'abc' and 'aac' is 1 as the second characters aren't the same
    """
    df = DataFrame()
    df.dna_string_one = collect(dna_string_one)
    df.dna_string_two = collect(dna_string_two)

    df.equal_nucleotide = map(eachrow(df)) do x
        x.dna_string_one == x.dna_string_two
    end

    hamming_distance = sum(df[!, 3])
    return hamming_distance
end


    ## RNA COMPLEMENT
function get_RNA_complement(dna_string)
    """
    Find the complementary nucleotide and switch it with the correct one in the dna_string.
    """
    compliment_pairs = Dict("C" => "G",
                            "A" => "U",
                            "G" => "C",
                            "T" => "A")

    replace(dna_string, r"C|A|G|T" => x -> compliment_pairs[x])
end


function run_length_encoding(input_string)
    """
    Take a string of repeated characters e.g. aaabbb and compress it to be reproducible later.
    aaabbb -> 3a3b
    aaccbb -> 2a2c2b
    dddddd -> 6d
    """
    countlist = []
    count = 1

    for x in 1:length(input_string) - 1
        if input_string[x + 1] == input_string[x]
            count += 1
        else
            push!(countlist, string(count) * input_string[x])
            count = 1
        end
    end
    push!(countlist, string(count) * input_string[length(input_string)])

    return string(countlist...)
end