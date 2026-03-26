# ==============================================================================
# Exercise: Does Open Science Help?
#
# You will walk Steps 3-6 of the causal inference roadmap hands-on:
# draw a DAG, assess assumptions, define the estimand, and estimate.
#
# Work in pairs. There are no wrong answers -- only different assumptions.
# When you are done, submit your results and come back to the main room.
# ==============================================================================

source("dagitty-helpers.R")
library(dagitty)

# ==============================================================================
# Roadmap Step 3: Draw a Causal DAG
# ==============================================================================

# You already know the question (Step 1) and the estimand (Step 2) from
# the slides. Now encode your assumptions as a graph.
#
# Open http://dagitty.net/dags.html in your browser.
#
# Click on Model -> New DAG. You should see a blank canvas.
# Left click to create a node, type in the name (exactly as below please,
# so the rest of the script works without errors).
# To move a node, click and drag it.
# To draw an arrow, click on a node, then click on another node.
# To bend the arrow, click on the arrow, then click and drag it.
# (This is just for aesthetics, it doesn't change the meaning of the DAG.)
#
# To delete a node, click on it and press d.
# To delete the arrow, repeat the same step like creating the arrow
# (click on a node, then click on the other node).
# To rename a variable, select it and tap r on your keyboard.
#
#
# Your system has 8 variables:
#
#   Novelty          -- how novel the research is
#   Rigour           -- methodological rigour of the study
#   Open Data        -- whether the data is shared openly
#   Published        -- whether the study is published in a journal
#   Data Reuse       -- whether others reuse the data
#   Reproducibility  -- whether the findings are reproducible
#   Field            -- the research field (e.g., psychology vs. physics)
#   Citations        -- number of citations received
#
# Think about the causal relationships and draw your version of the DAG.
# Each arrow is an assumption. Different pairs will draw different DAGs --
# that's the point.
#
# IMPORTANT: Name the nodes exactly as listed above so the R code
# below will work without errors.
#
# Steps:
#   1. Create the 8 nodes (use the exact names above)
#   2. Draw the arrows you think are plausible
#   3. Discuss with your partner -- where do you agree and disagree?


# ==============================================================================
# Roadmap Step 4: Assess Causal Assumptions
# ==============================================================================

# Now use dagitty to read the implications of your DAG.
#
# In dagitty.net, set the exposure and outcome:
#   - Click on "Open Data", then press E (or: Variable menu -> "exposure")
#   - Click on Citations, then press O (or: Variable menu -> "outcome")
#
# The graph should now light up with colors. Check the legend in the
# lower left corner of dagitty.net:
#   - Red nodes:    need to be conditioned on (adjustment set)
#   - Green lines:  causal paths (the effect you want to estimate)
#   - Red lines:    biasing paths (non-causal, need to be blocked)
#
# Write down: which variables does dagitty say you should control for?
#
# Answer: ___
#
#
# Now experiment with adjusting for different variables:
#   - Click on a node, then press A (or: Variable menu -> "adjusted")
#
# Observe what happens to the graph:
#   - When does bias disappear? (biasing paths turn from red to grey)
#   - When does NEW bias appear? (new red paths open up)
#
# Try:
#   - Adjust for a confounder. What happens?
#   - Adjust for a mediator (e.g., Data Reuse). What happens?
#   - Adjust for a collider. What happens?
#
# Reset your adjustments before moving on (click adjusted nodes, press A).


# ==============================================================================
# Roadmap Step 5: Define the Empirical Estimand
# ==============================================================================

# The theoretical estimand (tau) lives in counterfactual-land.
# The DAG is the bridge to data-land: it tells you WHICH variables
# to adjust for. That adjustment set defines your empirical estimand --
# the specific regression you need to run.
#
# In dagitty.net: Model -> Publish on dagitty.net
# At the bottom of the page, copy the dagitty model code.
# Paste it below between the quotes:

open_science_dag <- dagitty('')

plot(open_science_dag)

# Set the exposure and outcome:

exposures(open_science_dag) <- "Open Data"
outcomes(open_science_dag) <- "Citations"

# What does dagitty say you need to control for?
# This IS your empirical estimand -- it tells you which regression to run.

adjustmentSets(open_science_dag, type = "minimal")


# ==============================================================================
# Roadmap Step 6: Estimate the Causal Effect
# ==============================================================================

# Now you move from the DAG to data.
# The data is generated from the DAG above, with known true causal effects.
# Open Data -> Citations has a true total effect of about 5.4.
# (Based on: Klebel & Traag, 2024 -- Introduction to causality in science studies)

df <- simulate_open_science()

# Compare three strategies: no controls, DAG-informed, and causal salad.
# "Your DAG" shows what YOUR graph implies you should adjust for.
# Which one recovers the true effect?

plot_bias(df, open_science_dag)


# ==============================================================================
# Submit and return to the main room
# ==============================================================================

# Submit your DAG and bias plot to the gallery, then come back to the main room.
# We will compare DAGs and discuss as a group.

submit("Your names here")
