
# Supply_Chain  
Modeling a supply chain through the Dijkstra algorithm and the World Bank's Logistics Performance Index.

This work considers 169 countries as a **directed, fully connected graph**, where the nodes represent the largest cities in each country. The Dijkstra algorithm is applied to determine the “best” route from one country to another.

Since Dijkstra’s algorithm requires a **weighted graph**, the key challenge is to define what “best” means for a shipping company. Obviously, we want the shortest and fastest path, but also the safest and most cost-effective.  

To address this, I calculated the real distance between every pair of countries using the **haversine formula** and, most importantly, I incorporated the [World Bank's Logistics Performance Index (LPI)](https://datos.bancomundial.org/indicador/LP.LPI.OVRL.XQ), which rates countries on a scale from 1 to 5 based on factors such as:

- Efficiency of customs processes  
- Quality of trade and transport infrastructure  
- Competence of logistics services  

The cost of shipping from country **x** to country **y** is modeled as:

$$
C_{x, y} = \\frac{D_{x, y}}{I_y^3}
$$

Where:  
- $C_{x, y}$ is the cost of traveling from country **x** to country **y**  
- $D_{x, y}$ is the actual geographic distance between **x** and **y**  
- $I_y$ is the LPI score of country **y**  

Therefore, $C_{x, y}$ is used as the **weight** of the edge from **x** to **y**. Finally, the Dijkstra algorithm is used to compute the optimal route, which is then plotted on a world map.
