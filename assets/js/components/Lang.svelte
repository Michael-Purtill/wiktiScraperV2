<script>
    import * as _ from 'lodash';
    import { onMount } from 'svelte';
    
    
    let posLinks = [];
    onMount(async () => {
        let lang = window.location.pathname.split("/")[2];
        fetch("/api/posLinks/" + lang).then((r) => {return r.json()}).then((d) => {posLinks = _.filter(d.POSLinks, (l) => l != "") })
    })

</script>

<div>
    <h2 class="center">{window.location.pathname.split("/")[2]}</h2>
<div class="langInfoContainer flexContainer">
    {#each posLinks as link}
        <button>{link.split("Category:")[1].replaceAll("_", " ")}</button>
    {/each}
</div>
</div>

<style></style>