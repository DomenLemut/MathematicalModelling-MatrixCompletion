function Y = svt(Mo, Omega, epsilon, maxIter, tauScalar, deltaScalar)
    % Initialize parameters
    [n, m] = size(Mo);
    Y = zeros(n, m);
    X = zeros(n, m);

    ct = sum(sum(Omega));
    tau = tauScalar * (n + m) / 2;
    delta = deltaScalar * (n * m) / ct;
    iter = 0;

    % Iterate until convergence or maximum number of iterations
    for k = 1:maxIter
        iter = iter + 1;
        % Singular Value Decomposition
          %Y(isnan(Y) | isinf(Y)) = 0;
          [U, S, V] = svd(Y, 'econ');
          S = diag(S);
          S = max(S - tau, 0);
          r = sum(S > 0);  % rank after thresholding
          S = diag(S(1:r));
          U = U(:, 1:r);
          V = V(:, 1:r);

          % Update X
          X = U * S * V';

          % Projection onto the observed entries
          X_Omega = X .* Omega;

          % Check convergence
          if norm(X_Omega - Mo, 'fro') / norm(Mo, 'fro') < epsilon
              break;
          end

          % Update Y
          Y = Y + delta * ((Mo .* Omega) - X_Omega);
    end
    iter
    Y = X;
end
