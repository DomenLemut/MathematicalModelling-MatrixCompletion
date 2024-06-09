function noiseReduction_unknown = noiseReduction_unknown(image, knownValues)

  function Y = transform(A, dimens)
    [n1, n2] = size(A);
     n1 = n1 / dimens;
    for z = 1:dimens
        Y(:, :, z) = A((z-1)*n1+1 : z*n1, :);
    end
  end

  img = imread(image);
  znanihVrednosti = knownValues;  % Probability of known values

  [n1, n2, n3] = size(img);
  n = n1;
  m = n2;
  epsilon = 1e-06;
  pixel_treshold = 4;

  % Create matrices A and M
  A = zeros(n*n3, m);
  M = zeros(n*n3, m);

  % Initialize the matrices A and M
  for i = 1:n
      for j = 1:m
          % With probability znanihVrednosti, the pixel value is known
          if(rand() <= znanihVrednosti)
            for z = 0:(n3 - 1)
                A(i + n*z, j) = img(i, j, z + 1);
                M(i + n*z, j) = 1;
            end
          end

      end
  end
  n3

  % Run the matrix completion algorithm
  tauScalar = 50;
  deltaScalar = 1.2;
  tic
  Y = svt(A, M, epsilon, 50, tauScalar, deltaScalar);

  Yimg = transform(Y, n3);
  Aimg = transform(A, n3);

  % Reshape the 3-D matrices to 2-D before calculating the norm
  Yimg_reshaped = reshape(Yimg, [], size(Yimg, 3));
  orgSlika_reshaped = reshape(cast(Aimg, 'double'), [], size(Aimg, 3));
  napaka = norm(Yimg_reshaped - orgSlika_reshaped, 'fro');
  casIzvajanja = toc;

  % Display the reconstructed matrix
  Yimg = cast(Yimg, "uint8");

  figure;
  subplot(1, 2, 1);
  imshow(Yimg);
  title('Reconstructed Matrix (Y)');

  subplot(1, 2, 2);
  imshow(cast(Aimg, "uint8"));
  title('Observed Matrix');

  % Print the execution time and error
  disp(['Known values: ', num2str(znanihVrednosti), '%']);
  disp(['Epsilon: ', num2str(epsilon)]);
  disp(['Execution Time: ', num2str(casIzvajanja), ' seconds']);
  disp(['Reconstruction Error: ', num2str(napaka)]);

end;
