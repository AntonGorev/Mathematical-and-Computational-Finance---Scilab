clc
clear

function [V0, V_am, S, q] = UpOutPut_BinMod(S0, r, sigma, T, M, B, K)
    
    delta_t = T / M
    
    // Calculate parameters u/d (up and down movements), beta, and probobilities
    b = 0.5 * (exp(-r * delta_t) + exp((r + sigma^2) * delta_t))
    u = b + sqrt(b^2 - 1)
    d = u^(-1)
    
    q = (exp(r * delta_t) - d) / (u - d)
    q_tilde = (q * u) / exp(r * delta_t)             // -"- for Stock
    
    // Define and calculate matrix of prices (i.e. binomial tree)
    S(1, 1) = S0
    for i = 1 : M
        for j = 0 : i
            S(j+1, i+1) = S0 * u^j * d^(i - j)
        end
    end
    
    size_S = size(S)
    
    V_am = zeros(size_S(1), size_S(2))
    
    // Calculate option values at maturity, initial conditions 
    //  (use 2.16 and Barrier)
    V_am(:,$) = max( K - S(:, $), 0 ) .* (S(:, $) < B )
    
    // Calculate option prices through whole tree (American Put) (use 2.15 for put)
    for n = size_S(2):-1:2
        V_am(1 : n - 1, n - 1) = exp(-r * delta_t) * ...
                                 ( q * V_am(2 : n, n) + (1 - q) * V_am(1 : n - 1, n)).* ...
                                 (S(1 : n - 1, n - 1) < B )
    end

    // Calculate American Put
    V0 = V_am(1,1)
    
endfunction


// Test data
S0 = 100
r = 0.05
sigma = 0.2
T = 1
K = 100
B = 110
M = 1000

// Test function and display result
[V0, V_am, S] = UpOutPut_BinMod(S0, r, sigma, T, M, B, K)
disp("Approximation to the price of an American put option using CRR model with Barrier is V0 = " ...
      + string(V0))
