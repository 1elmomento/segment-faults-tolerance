using Plots
using Plots.PlotMeasures
using Combinatorics
gr()

digit_map = Dict(
	[1, 1, 1, 1, 1, 1, 0] => 0,
	[0, 1, 1, 0, 0, 0, 0] => 1,
	[1, 1, 0, 1, 1, 0, 1] => 2,
	[1, 1, 1, 1, 0, 0, 1] => 3,
	[0, 1, 1, 0, 0, 1, 1] => 4,
	[1, 0, 1, 1, 0, 1, 1] => 5,
	[1, 0, 1, 1, 1, 1, 1] => 6,
	[1, 1, 1, 0, 0, 0, 0] => 7,
	[1, 1, 1, 1, 1, 1, 1] => 8,
	[1, 1, 1, 1, 0, 1, 1] => 9,
)

function toggle_zeros(array)
	zero_indices = findall(x -> x == 0, array)
	subsets = powerset(zero_indices)

	results = []
	for subset in subsets
		toggled_array = copy(array)
		for idx in subset
			toggled_array[idx] = 1
		end
		push!(results, toggled_array)
	end

	return results
end

function calculate_fault_ambiguities()
	results = []
	for digit in keys(digit_map)
		for index in eachindex(digit)
			copied_segment = copy(digit)
			copied_segment[index] = 0
			subsets = toggle_zeros(copied_segment)

			matches = 0
			for subset in subsets
				if subset in keys(digit_map)
					matches += 1
				end
			end
			push!(results, [index, matches, digit])
		end
	end

	updated_results = [(x[1], x[2], digit_map[x[3]]) for x in results]
	return updated_results
end

function plot_results(data)
	grouped_data = Dict()
	for (removed_segment, ambiguities, digit) in data
		if !haskey(grouped_data, digit)
			grouped_data[digit] = []
		end
		push!(grouped_data[digit], (removed_segment, ambiguities))
	end

	digits = sort(collect(keys(grouped_data)))
	plots = []
	for (i, digit) in enumerate(digits)
		group = grouped_data[digit]
		segments = [x[1] for x in group]
		ambiguities = [x[2] for x in group]

		bar_plot = bar(
			segments,
			ambiguities,
			xlabel = "Removed Segment",
			ylabel = "Ambiguities",
			title = "Digit $digit",
			xticks = 1:7,
			legend = false,
			color = parse(Colorant, "#FFB200"),
			linecolor = :black,
			linewidth = 0.4,
		)

		plt = plot!(bar_plot, size = (1200, 600), margin = 1cm)
		savefig(plt, "plots/plot_digit_$digit")

		push!(plots, bar_plot)
	end

	rows = 2
	cols = ceil(Int, (length(digits) / rows))

	final_plot = plot(
		plots...,
		layout = (rows, cols),
		size = (1200, 800),
		margin = 5mm,
		guidefontsize = 10,
		tickfontsize = 8,
	)
	savefig(final_plot, "plots/combined_plot.png")
end

function main()
	results = calculate_fault_ambiguities()
	plot_results(results)
end

if abspath(PROGRAM_FILE) == @__FILE__
	main()
end