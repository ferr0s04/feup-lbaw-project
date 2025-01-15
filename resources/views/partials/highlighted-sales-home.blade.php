<div class="highlighted-slider game-slider-container">
    <div class="slider-top">
        <h1>Highlighted Games</h1>
        <a href="{{ route('games.highlighted') }}" class="see-all-button">
            See All&nbsp;&nbsp; 
            <i class="fa-solid fa-chevron-right"></i>
        </a>
    </div>
    <button class="slider-arrow left-arrow">&#10094;</button>
    <div class="game-slider">
        @foreach($highlightedGames->take(10) as $index => $game)
            @include('partials.game-card-vertical', ['game' => $game])
        @endforeach
    </div>
    <button class="slider-arrow right-arrow">&#10095;</button>
</div>

<div class="sales-slider game-slider-container">
    <div class="slider-top">
        <h1>Sales</h1>
        <a href="{{ route('games.sales') }}" class="see-all-button">
            See All&nbsp;&nbsp; 
            <i class="fa-solid fa-chevron-right"></i>
        </a>
    </div>
    <button class="slider-arrow left-arrow">&#10094;</button>
    <div class="game-slider">
        @foreach($sales->take(10) as $index => $game)
            @include('partials.game-card-vertical', ['game' => $game])
        @endforeach
    </div>
    <button class="slider-arrow right-arrow">&#10095;</button>
</div>


<script>
document.addEventListener("DOMContentLoaded", () => {
    document.querySelectorAll('.game-slider-container').forEach(sliderContainer => {
        const slider = sliderContainer.querySelector('.game-slider');
        const leftArrow = sliderContainer.querySelector('.left-arrow');
        const rightArrow = sliderContainer.querySelector('.right-arrow');
        const gameCards = slider.querySelectorAll('.game-card-vertical');
        const totalGames = gameCards.length;
        let currentIndex = 0;

        function getGamesToShow() {
            return window.innerWidth <= 768 ? 1 : 4;
        }

        function moveSlider(direction) {
            const gamesToShow = getGamesToShow();
            currentIndex += direction;

            if (currentIndex < 0) {
                currentIndex = 0;
            } else if (currentIndex > totalGames - gamesToShow) {
                currentIndex = totalGames - gamesToShow;
            }

            const newTransformValue = -(currentIndex * (100 / gamesToShow)) + '%';
            slider.style.transform = `translateX(${newTransformValue})`;
        }

        leftArrow.addEventListener('click', () => moveSlider(-1));
        rightArrow.addEventListener('click', () => moveSlider(1));

        window.addEventListener('resize', () => {
            currentIndex = 0;
            slider.style.transform = 'translateX(0%)';
        });
    });
});

document.addEventListener("DOMContentLoaded", () => {
    const gameSliders = document.querySelectorAll('.game-slider');

    gameSliders.forEach(slider => {
        const gameCards = slider.querySelectorAll('.game-card-vertical');
        
        function updateCardWidth() {
            const sliderWidth = slider.offsetWidth;
            const cardWidth = (sliderWidth * 25 / 100) - 20;
            const cardWidthPercentage = (cardWidth / sliderWidth) * 100;

            gameCards.forEach(card => {
                card.style.flexBasis = `${cardWidthPercentage}%`;
            });
        }

        updateCardWidth();
        window.addEventListener('resize', updateCardWidth);
    });
});

</script>