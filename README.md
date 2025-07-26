# Suply_Chain
Modeling a supply chain through the Dijkstra algorithm and World Bank's Logistics Performance Index.

This work takes 169 countries like an directed, fully conected graph fully where the nodes are the bigest cities from each country and aplies the Dijstrak algorithm to know the "best" way to go from a country to another one.
But, since the Dijstrak algorithm requires a weighted graph, the key point is how to know what is the best for a shipping company, beacuse it's clear that we want the shortest and fastest way but at the same time we want the seafest and cheapest way possible: To face this problem I calculed the real distance between every couple of contries using the Harvesting formula and most importante, I used the [World Bank's Logistics Performance Index](https://datos.bancomundial.org/indicador/LP.LPI.OVRL.XQ) wich gives every country an 1-5 logistic punctuation considering the efficiency of the customs process, the infrastucture quality related with commerce and transport and took a proportion like

$ C_{x, y} = D_{x, y} / I_y

where:
- C_{x, y} is the cost asociated to go to y country from x country.
- D_{x, y} is the real distance between x and y
- I_y is the y's Logistics Performance Index

So, $C_{x, y}$ is the weight of the edge x -> y, and finally I used the Dijstrak algorithm and plotted the route.


# Supply_Chain  
Modeling a supply chain through the Dijkstra algorithm and the World Bank's Logistics Performance Index.

This work considers 169 countries as a **directed, fully connected graph**, where the nodes represent the largest cities in each country. The Dijkstra algorithm is applied to determine the “best” route from one country to another.

Since Dijkstra’s algorithm requires a **weighted graph**, the key challenge is to define what “best” means for a shipping company. Obviously, we want the shortest and fastest path, but also the safest and most cost-effective.  

To address this, I calculated the real distance between every pair of countries using the **haversine formula**. Most importantly, I incorporated the [World Bank's Logistics Performance Index (LPI)](https://datos.bancomundial.org/indicador/LP.LPI.OVRL.XQ), which rates countries on a scale from 1 to 5 based on factors such as:

- Efficiency of customs processes  
- Quality of trade and transport infrastructure  
- Competence of logistics services  

The cost of shipping from country **x** to country **y** is modeled as:

\\[
C_{x, y} = \\frac{D_{x, y}}{I_y^3}
\\]

Where:  
- \\(C_{x, y}\\) is the cost of traveling from country **x** to country **y**  
- \\(D_{x, y}\\) is the actual geographic distance between **x** and **y**  
- \\(I_y\\) is the LPI score of country **y**  

Therefore, \\(C_{x, y}\\) is used as the **weight** of the edge from **x** to **y**. Finally, the Dijkstra algorithm is used to compute the optimal route, which is then plotted on a world map.
