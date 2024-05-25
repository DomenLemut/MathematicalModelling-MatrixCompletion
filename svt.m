function [Y, iter] = svt(Mo, Omega, epsilon, maxIter)
    % Initialize parameters
    [n, m] = size(Mo);
    Y = zeros(n, m);
    X = zeros(n, m);

    ct = sum(sum(Omega));
    tau = 5 * (n + m) / 2;
    delta = 1.2 * (n * m) / ct;
    iter = 0;
    p = 0;

    % Iterate until convergence or maximum number of iterations
    for k = 1:maxIter
        iter = iter + 1;

        % Singular Value Decomposition
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
        Y = Y + delta * (Mo - X_Omega);
    end

    Y = X;
end
