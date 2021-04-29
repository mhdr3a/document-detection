function [] = detect_page(fileName, salt_pepper_ratio_H, salt_pepper_ratio_V, accuracyUp, accuracyDown, accuracyLeft, accuracyRight, precision)
    page = imread("./data/data/" + fileName);
    page = im2double(rgb2gray(page));
    
    line_H = [-1 -1 -1; 2 2 2; -1 -1 -1];
    line_V = [-1 2 -1; -1 2 -1; -1 2 -1];

    liH = abs(conv2(page, line_H));
    liH = medfilt2(liH, [salt_pepper_ratio_H salt_pepper_ratio_H]);
    pageSize = size(liH);
    pageUp = liH(1:floor(pageSize(1)/2), :);
    pageDown = liH(floor(pageSize(1)/2):end, :);

    cornersUp = detectHarrisFeatures(pageUp);
    cornersDown = detectHarrisFeatures(pageDown);
    cornersUp = cornersUp.selectStrongest(precision);
    cornersDown = cornersDown.selectStrongest(precision);

    pointsUp = cornersUp.Location;

    pointsDown = cornersDown.Location;

    Yup = pointsUp(:,2);
    SqrDistUp = zeros(precision);
    for i = 1:precision
        for j = 1:precision
            SqrDistUp(i,j) = (Yup(i) - Yup(j))^2;
        end
    end
    SqrDistUp = sum(SqrDistUp, 1);
    SqrDistUp = SqrDistUp / max(SqrDistUp);
    if accuracyUp == -1
        accuracyUp = mean(SqrDistUp);
    end

    cornersUp = cornersUp(SqrDistUp < accuracyUp);
    figure;
    imshow(pageUp),
    hold on,
    plot(cornersUp);

    lineUp = fit(cornersUp.Location(:,1), cornersUp.Location(:,2), 'poly1');

    YDown = pointsDown(:,2);
    SqrDistDown = zeros(precision);
    for i = 1:precision
        for j = 1:precision
            SqrDistDown(i,j) = (YDown(i) - YDown(j))^2;
        end
    end
    SqrDistDown = sum(SqrDistDown, 1);
    SqrDistDown = SqrDistDown / max(SqrDistDown);
    if accuracyDown == -1
        accuracyDown = mean(SqrDistDown);
    end

    cornersDown = cornersDown(SqrDistDown < accuracyDown);
    figure;
    imshow(pageDown),
    hold on,
    plot(cornersDown);

    lineDown = fit(cornersDown.Location(:,1), cornersDown.Location(:,2), 'poly1');

    liV = abs(conv2(page, line_V));
    liV = medfilt2(liV, [salt_pepper_ratio_V salt_pepper_ratio_V]);
    pageSize = size(liV);
    pageLeft = liV(:, 1:floor(pageSize(2)/2));
    pageRight = liV(:, floor(pageSize(2)/2):end);

    cornersLeft = detectHarrisFeatures(pageLeft);
    cornersRight = detectHarrisFeatures(pageRight);
    cornersLeft = cornersLeft.selectStrongest(precision);
    cornersRight = cornersRight.selectStrongest(precision);

    pointsLeft = cornersLeft.Location;

    pointsRight = cornersRight.Location;

    XLeft = pointsLeft(:,1);
    SqrDistLeft = zeros(precision);
    for i = 1:precision
        for j = 1:precision
            SqrDistLeft(i,j) = (XLeft(i) - XLeft(j))^2;
        end
    end
    SqrDistLeft = sum(SqrDistLeft, 1);
    SqrDistLeft = SqrDistLeft / max(SqrDistLeft);
    if accuracyLeft == -1
        accuracyLeft = mean(SqrDistLeft);
    end

    cornersLeft = cornersLeft(SqrDistLeft < accuracyLeft);
    figure;
    imshow(pageLeft),
    hold on,
    plot(cornersLeft);

    lineLeft = fit(cornersLeft.Location(:,2), cornersLeft.Location(:,1), 'poly1');

    XRight = pointsRight(:,1);
    SqrDistRight = zeros(precision);
    for i = 1:precision
        for j = 1:precision
            SqrDistRight(i,j) = (XRight(i) - XRight(j))^2;
        end
    end
    SqrDistRight = sum(SqrDistRight, 1);
    SqrDistRight = SqrDistRight / max(SqrDistRight);
    if accuracyRight == -1
        accuracyRight = mean(SqrDistRight);
    end

    cornersRight = cornersRight(SqrDistRight < accuracyRight);
    figure;
    imshow(pageRight),
    hold on,
    plot(cornersRight);

    lineRight = fit(cornersRight.Location(:,2), cornersRight.Location(:,1), 'poly1');

    up = @(y) lineUp.p1 * y + lineUp.p2;
    down = @(y) lineDown.p1 * y + lineDown.p2 + floor(pageSize(1)/2);
    left = @(x) (x - lineLeft.p2)/lineLeft.p1;
    right = @(x) (x - lineRight.p2 - floor(pageSize(2)/2))/lineRight.p1;
    syms m
    x11 = solve(up(m) == left(m), m);
    y11 = left(x11);
    x21 = solve(up(m) == right(m), m);
    y12 = right(x21);
    x12 = solve(down(m) == left(m), m);
    y21 = left(x12);
    x22 = solve(down(m) == right(m), m);
    y22 = right(x22);
    x1 = (x11 + x12)/2;
    x2 = (x21 + x22)/2;
    y1 = (y11 + y12)/2;
    y2 = (y21 + y22)/2;
    a = ceil(double(x2 - x1));
    b = ceil(double(y2 - y1));
    x1 = floor(double(x1));
    y1 = ceil(double(y1));

    warning('off', 'all');
    page = imread("./data/data/" + fileName);
    figure;
    imshow(page),
    title("Main Image"),
    rectangle('Position', [x1 y1 a b], 'EdgeColor', 'red', 'LineWidth', 3);
end
